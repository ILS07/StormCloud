USE [FINDATA]
GO

-------------------------------------------------------------------------------------------------
-- Add new FRED Category
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Add_FRED_Category]
(
    @parentCatID INT
    ,@thisCatID INT
    ,@thisCatName VARCHAR(100)
)

AS
BEGIN
    IF ((@parentCatID IS NULL) OR (@thisCatID IS NULL) OR (@thisCatName IS NULL))
    BEGIN
        RAISERROR('One or more parameters are NULL.',16,1)
    END

    DECLARE @newID HIERARCHYID
    DECLARE @parentID HIERARCHYID = (SELECT [FredCatNode] FROM [dbo].[FRED_CATEGORY] WHERE [FredCatID] = @parentCatID)
    DECLARE @deepNode HIERARCHYID = (SELECT MAX(FredCatNode) FROM [dbo].[FRED_CATEGORY] WHERE [FredCatNode].GetAncestor(1) = @parentID)

    SET @newID = (SELECT [FredCatNode].GetDescendant(@deepNode,null) AS [NewNode] FROM [dbo].[FRED_CATEGORY] WHERE [FredCatNode] = @parentID)

    INSERT INTO [dbo].[FRED_CATEGORY] VALUES (@newID, @thisCatID, @thisCatName, GETDATE())
END
GO

-------------------------------------------------------------------------------------------------
-- Add new FRED Series
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Add_FRED_Series]
(
    @seriesID VARCHAR(60)
    ,@categoryID INT
    ,@seriesTitle VARCHAR(120)
    ,@isActive BIT
    ,@observeStart DATE
    ,@observeEnd DATE
    ,@freqLabel VARCHAR(100)
    ,@unitLabel VARCHAR(100)
    ,@adjusted BIT
    ,@published DATETIME2(0)
)

AS
BEGIN
    DECLARE @freqID TINYINT = (SELECT TOP(1) [FredFreqID] FROM [dbo].[FRED_SERIES_FREQUENCY] WHERE [FredFreqLabel] = @freqLabel)
    DECLARE @unitID SMALLINT = (SELECT TOP(1) [FredUnitID] FROM [dbo].[FRED_SERIES_UNIT] WHERE [FredUnitLabel] = @unitLabel)

    IF @freqID IS NULL
    BEGIN
        INSERT INTO [dbo].[FRED_SERIES_FREQUENCY] VALUES (@freqLabel)
        SET @freqID = (SELECT [FredFreqID] FROM [dbo].[FRED_SERIES_FREQUENCY] WHERE [FredFreqLabel] = @freqLabel)
    END

    IF @unitID IS NULL
    BEGIN
        INSERT INTO [dbo].[FRED_SERIES_UNIT] VALUES (@unitLabel)
        SET @unitID = (SELECT [FredUnitID] FROM [dbo].[FRED_SERIES_UNIT] WHERE [FredUnitLabel] = @unitLabel)
    END

    INSERT INTO [dbo].[FRED_SERIES] VALUES (@seriesID, @categoryID, @seriesTitle, @isActive, @observeStart,
        @observeEnd, @freqID, @unitID, @adjusted, NULL, GETDATE(), @published)
END
GO

-------------------------------------------------------------------------------------------------
-- Add new market index
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Add_Market_Index]
( @indexCode VARCHAR(15) )

AS
BEGIN
    DECLARE @indexID TINYINT 
    SET @indexID = (SELECT TOP(1) [IndexID] FROM [dbo].[MARKET_INDEX] WHERE [IndexCode] = @indexCode)

    IF @indexID IS NULL
    BEGIN
        INSERT INTO [dbo].[MARKET_INDEX] VALUES (@indexCode,NULL)
        SET @indexID = (SELECT TOP(1) [IndexID] FROM [dbo].[MARKET_INDEX] WHERE [IndexCode] = @indexCode)
    END

    SELECT @indexID AS [IndexID]
END
GO

-------------------------------------------------------------------------------------------------
-- Add new stock
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Add_Stock]
(
    @stockSymbol VARCHAR(12)
    ,@stockName VARCHAR(60)
    ,@isActive BIT
    ,@exchCode CHAR(4)
    ,@cusip CHAR(9)
    ,@cik CHAR(10)
    ,@isin CHAR(12)
    ,@sic SMALLINT
    ,@options BIT
    ,@dividend BIT
    ,@gics VARCHAR(8)
)

AS
BEGIN
    DECLARE
        @check VARCHAR(12) = (SELECT [StockSymbol] FROM [dbo].[STOCK] WHERE [StockSymbol] = @stockSymbol)
        ,@exchID SMALLINT = (SELECT TOP(1) [ExchangeID] FROM [dbo].[EXCHANGE] WHERE [ExchangeMIC] = @exchCode)
        ,@gicsID HIERARCHYID = (SELECT [GicsNode] FROM [dbo].[GICS] WHERE [GicsCode] = @gics)

    IF @check IS NOT NULL
    BEGIN
        RAISERROR('Symbol already exists.',16,1)
    END

    IF @sic = 0
    BEGIN
        SET @sic = NULL
    END

    INSERT INTO [dbo].[STOCK] VALUES (@stockSymbol,@stockName,@isActive,@exchID,@cusip,@cik,@isin,@sic,@options,
        @dividend,@gicsID,GETDATE(),GETDATE()) --Removed NULL x8 for Last***
END
GO

-------------------------------------------------------------------------------------------------
-- Synchronize short interest
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Sync_Short_Interest]
( @stockSymbol VARCHAR(12) )

AS
BEGIN
    DECLARE
        @stockID INT = (SELECT [StockID] FROM [FINDATA].[dbo].[STOCK] WHERE [StockSymbol] = @stockSymbol)
        ,@mostRecent DATE

    IF @stockID IS NULL
    BEGIN
        RAISERROR('Symbol not found.',16,1)
    END

    SET @mostRecent = (SELECT MAX([SettlementDate]) FROM [FINDATA].[dbo].[SHORT_INTEREST] WHERE [StockID] = @stockID)

    IF @mostRecent IS NULL
    BEGIN
        SET @mostRecent = '1900-01-01'
    END

    INSERT INTO [FINDATA].[dbo].[SHORT_INTEREST]
        SELECT
        [stk].[StockID]
        ,[shrt].[SettlementDate]
        ,[shrt].[DaysToCover]
        ,[shrt].[AvgDailyVolume]
        ,[shrt].[CurrentShortQty]
        ,[shrt].[PreviousShortQty]
        ,[shrt].[ChangePercent]
        ,[shrt].[ChangeShortQty]
        FROM [FINDATA].[dbo].[STOCK] [stk]
        INNER JOIN [BULKDATA].[dbo].[SHORT_INTEREST] [shrt]
            ON [stk].[StockSymbol] = [shrt].[Symbol]
        WHERE [stk].[StockSymbol] = @stockSymbol AND [shrt].[SettlementDate] > @mostRecent
END
GO

-------------------------------------------------------------------------------------------------
-- Synchronize SEC Filings
-------------------------------------------------------------------------------------------------
CREATE PROCEDURE [dbo].[Sync_SEC_Filing]
( @stockSymbol VARCHAR(12) )

AS
BEGIN
    DECLARE
        @stockID INT = (SELECT [StockID] FROM [FINDATA].[dbo].[STOCK] WHERE [StockSymbol] = @stockSymbol)
        ,@mostRecent DATE

    IF @stockID IS NULL
    BEGIN
        RAISERROR('Symbol not found.',16,1)
    END

    SET @mostRecent = (SELECT MAX([DateFiled]) FROM [FINDATA].[dbo].[SEC_FILING_INDEX] WHERE [StockID] = @stockID)

    IF @mostRecent IS NULL
    BEGIN
        SET @mostRecent = '1900-01-01'
    END

    INSERT INTO [FINDATA].[dbo].[SEC_FILING_INDEX]
        SELECT [stk].[StockID]
        ,[sec].[DateFiled]
        ,[frm].[FormID]
        ,[sec].[FileName]
        FROM [FINDATA].[dbo].[STOCK] [stk]
        INNER JOIN [BULKDATA].[dbo].[vw_SEC_INDEX] [sec]
            ON [stk].[CIK] = [sec].[CIK]
		INNER JOIN [FINDATA].[dbo].SEC_FILING_FORM [frm]
			ON [frm].[FormType] = [sec].[FormType]
        WHERE [stk].[StockSymbol] = @stockSymbol AND [sec].[DateFiled] > @mostRecent

END
GO