Function New-FinanceDatabase
{
    [CmdletBinding()]
    param ( [Parameter()][Switch]$NoTables = $false )

    BEGIN
    {
        $serv = $null

        Write-Output "This module was designed with the newer 'SqlServer' PowerShell module."
        Write-Output "For maximum compatability and reliability, ensure that 'SqlServer' is installed."
        Write-Output "The default 'SQLPS' module that ships with SQL Server will be used if 'SqlServer' is not available."
        Write-Output "---------------------------------------------------------------------------------------------------"

        if (Test-Path "HKLM:\Software\Microsoft\Microsoft SQL Server\Instance Names\SQL")
        {
            Write-Host "SQL Server Installed..." -NoNewline; Write-Host "Check" -ForegroundColor Green
            Write-Host "Importing PowerShell module..." -NoNewline

            switch (((Get-Module -ListAvailable -Name *sql*).Name))
            {
                { $_ -contains "SqlServer" }  { Import-Module -Name SqlServer; Write-Host "SqlServer" -ForegroundColor Green; break }
                { $_ -contains "SQLPS"} { Import-Module -Name SQLPS; Write-Host "SQLPS" -ForegroundColor Yellow; break }
                Default { Write-Host "No compatible module found!" -ForegroundColor Red; return $null }
            }

            Write-Host "SQL Server service..." -NoNewline

            if (($serv = Get-Service -DisplayName "SQL Server (*").Status -eq "Running")
            { Write-Host "Running" -ForegroundColor Green }
            else
            {
                try
                {
                    Write-Host "Starting" -ForegroundColor Yellow -NoNewline; Write-Host "..." -NoNewline
                    Start-Service -Name $serv.Name

                    while ($serv.Status -ne "Running")
                    { Start-Sleep -Seconds 2; $serv.Refresh() }

                    Write-Host "Running" -ForegroundColor Green
                }
                catch
                {
                    Write-Host "Failed" -ForegroundColor Red
                    Write-Output "The '$($serv.Name)' service was found, but it could not be started!"; return $null
                }
            }
        }
        else { Write-Host "No installation of SQL found!" -ForegroundColor Red; return $null }
    }

    PROCESS
    {
        switch ((Invoke-Sqlcmd -Query "IF DB_ID('$Script:database') IS NULL SELECT 'Install' AS Result ELSE SELECT 'NoInstall' AS Result").Result)
        {
            "Install"
            {
                $sql = Invoke-Sqlcmd -Query "SELECT SERVERPROPERTY('InstanceDefaultDataPath') AS [DataPath], SERVERPROPERTY('InstanceDefaultLogPath') AS [LogPath], SERVERPROPERTY('ProductMajorVersion') AS [Version]"
                $ledger = if ($sql.Version -ge 16) { ", LEDGER = OFF" }

                Invoke-Sqlcmd -Query `
                    ("USE [master]
                    GO
            
                    CREATE DATABASE [$Script:database]
                    CONTAINMENT = NONE
                    ON  PRIMARY 
                    ( NAME = N'$Script:database', FILENAME = N'$($sql.DataPath)$Script:database.mdf' , SIZE = 10GB , MAXSIZE = UNLIMITED, FILEGROWTH = 10GB )
                    LOG ON 
                    ( NAME = N'$Script:database`_log', FILENAME = N'$($sql.LogPath)$Script:database`_log.ldf' , SIZE = 10GB , MAXSIZE = 2048GB , FILEGROWTH = 10GB )
                    WITH CATALOG_COLLATION = DATABASE_DEFAULT$ledger
                    GO
                    
                    IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
                    BEGIN
                    EXEC $Script:database.[dbo].[sp_fulltext_database] @action = 'enable'
                    END
                    GO"
                )

                if (!($NoTables.IsPresent))
                {
                    $root = (Get-Item $PSScriptRoot).Parent.FullName

                    Write-Host "Creating data tables..." -NoNewline
                    Invoke-Sqlcmd -InputFile "$root\Private\SQL\DataTables.sql"
                    Write-Host "Complete" -ForegroundColor Green
                    Write-Host "Creating stored procedures..." -NoNewline
                    Invoke-Sqlcmd -InputFile "$root\Private\SQL\StoredProcs.sql"
                    Write-Host "Complete" -ForegroundColor Green
                    Write-Host "Creating views..." -NoNewline
                    Invoke-Sqlcmd -InputFile "$root\Private\SQL\Views.sql"
                    Write-Host "Complete" -ForegroundColor Green
                    Write-Host "Populating base data..." -NoNewline
                    Invoke-Sqlcmd -InputFile "$root\Private\SQL\BaseData.sql"
                    Write-Host "Complete" -ForegroundColor Green
                }

                Write-Host "The database has been created successfully!" -ForegroundColor Green
            }

            "NoInstall"
            { Write-Output "The database already exists!" }
        }
    }
}