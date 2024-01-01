USE [FINDATA]
GO

-------------------------------------------------------------------------------------------------
-- Stock Classification by Sector, Group, Industry, and Sub-Industry
-------------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[vw_Stock_Classification]
AS
    SELECT 
	[StockSymbol] AS [Symbol]
	,[StockName] AS [Name]
	,(SELECT [GicsLabel] FROM [dbo].[GICS] WHERE ([GicsNode] = ([dbo].[Stock].[GICS]).GetAncestor(3))) AS [Sector]
	,(SELECT [GicsLabel] FROM [dbo].[GICS] WHERE ([GicsNode] = ([dbo].[Stock].[GICS]).GetAncestor(2))) AS [Group]
	,(SELECT [GicsLabel] FROM [dbo].[GICS] WHERE ([GicsNode] = ([dbo].[Stock].[GICS]).GetAncestor(1))) AS [Industry]
	,(SELECT [GicsLabel] FROM [dbo].[GICS] WHERE ([GicsNode] = ([dbo].[Stock].[GICS]).GetAncestor(0))) AS [SubIndustry]
	FROM [dbo].[Stock]
GO

-------------------------------------------------------------------------------------------------
-- Find any stocks that have NULL values for Pricing Data
-------------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[vw_Null_Price_Data]
AS
	SELECT
	[stk].[StockSymbol]
	,[stk].[StockName]
	,[dbo].[PRICE_HISTORY].[PriceDate]
	,[dbo].[PRICE_HISTORY].[HighPrice]
	,[dbo].[PRICE_HISTORY].[LowPrice]
	,[dbo].[PRICE_HISTORY].[ClosePrice]
	,[dbo].[PRICE_HISTORY].[AdjClosePrice]
	,[dbo].[PRICE_HISTORY].[Volume]
	FROM [dbo].[STOCK] AS [stk]
	INNER JOIN [dbo].[PRICE_HISTORY] ON [stk].[StockID] = dbo.[PRICE_HISTORY].[StockID]
	WHERE ([dbo].[PRICE_HISTORY].[ClosePrice] IS NULL)
GO

-------------------------------------------------------------------------------------------------
-- View Volume by Sector per Date
-------------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[vw_Volume_By_Sector_By_Date]
AS
	SELECT
	[class].[Sector]
	,[price].[PriceDate]
	,SUM([price].[Volume]) AS DailyVolume
	FROM [dbo].[vw_Stock_Classification] [class]
	INNER JOIN [dbo].[STOCK] [stk] ON [class].[Symbol] = [stk].[StockSymbol]
	INNER JOIN [dbo].[PRICE_HISTORY] AS [price] ON [price].[StockID] = [stk].[StockID]
	GROUP BY [class].[Sector], [price].[PriceDate]
GO

-------------------------------------------------------------------------------------------------
-- View SEC Filing Information
-------------------------------------------------------------------------------------------------

CREATE VIEW [dbo].[vw_SEC_Filing]
AS
	SELECT [stk].[StockSymbol]
	,[sec].[DateFiled]
	,[frm].[FormType]
	,[frm].[FormDescription]
	,[sec].[FileName] AS [FilingIdent]
	FROM [dbo].[STOCK] [stk]
	INNER JOIN [dbo].[SEC_FILING_INDEX] [sec] ON [stk].[StockID] = [sec].[StockID]
	INNER JOIN [dbo].[SEC_FILING_FORM] [frm] ON [sec].[FormID] = [frm].[FormID]
GO