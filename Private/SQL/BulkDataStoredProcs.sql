USE [BULKDATA]
GO

CREATE PROCEDURE [dbo].[Add_SEC_Filing]
(
    @dateFiled DATE
    ,@cik CHAR(10)
    ,@formType VARCHAR(20)
    ,@fileName VARCHAR(45)
)

AS
BEGIN
    IF ((@dateFiled IS NULL) OR (@cik IS NULL) OR (@formType IS NULL) OR (@fileName IS NULL))
    BEGIN
        RAISERROR('One or more parameters are NULL.',16,1)
    END

    DECLARE @cikID INT = (SELECT [CIKID] FROM [dbo].[SEC_FILING_CIK] WHERE [CIK] = @cik)
    DECLARE @formID SMALLINT = (SELECT [FormID] FROM [dbo].[SEC_FILING_FORM] WHERE [FormType] = @formType)

    IF @cikID IS NULL
    BEGIN
        INSERT INTO [dbo].[SEC_FILING_CIK] VALUES (@cik)
        SET @cikID = (SELECT MAX([CIKID]) FROM [dbo].[SEC_FILING_CIK])
    END

    IF @formID IS NULL
    BEGIN
        INSERT INTO [dbo].[SEC_FILING_FORM] VALUES (@formType,NULL)
        SET @formID = (SELECT MAX([FormID]) FROM [dbo].[SEC_FILING_FORM])
    END

    -- Easiest way to keep tables in sync is to write to both databases at the same time.
    INSERT INTO [BULKDATA].[dbo].[SEC_FILING_INDEX] VALUES (@dateFiled,@cikID,@formID,@fileName)
	INSERT INTO [FINDATA].[dbo].[SEC_FILING_FORM] VALUES (@formID,@formType,NULL)
END
GO