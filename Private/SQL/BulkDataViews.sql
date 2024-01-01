USE [BULKDATA]
GO

CREATE VIEW [dbo].[vw_SEC_INDEX]
AS
    SELECT
    [idx].[DateFiled], [form].[FormType], [cik].[CIK], [idx].[FileName]
    FROM [dbo].[SEC_FILING_CIK] AS [cik]
    INNER JOIN [dbo].[SEC_FILING_INDEX] AS [idx] ON [cik].[CIKID] = [idx].[CIKID]
    INNER JOIN [dbo].[SEC_FILING_FORM] AS [form] ON [idx].[FormID] = [form].[FormID]
GO