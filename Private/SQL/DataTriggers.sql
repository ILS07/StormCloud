USE [FINDATA]
GO

CREATE TRIGGER [dbo].[trg_Stock_IUD] ON [dbo].[STOCK]
    AFTER INSERT,UPDATE,DELETE
AS
BEGIN
    UPDATE [dbo].[PBI_STATS] SET
        [SymCount] = (SELECT COUNT(*) FROM [dbo].[STOCK])
        ,[SymActive] = (SELECT COUNT(*) FROM [dbo].[STOCK] WHERE [IsActive] = 1)
        ,[SymInactive] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [IsActive] = 0)
        ,[SymOptions] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [HasOptions] = 1)
        ,[SymDividends] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [HasDividend] = 1)
END
GO

CREATE TRIGGER [dbo].[trg_FRED_IUD] ON [dbo].[FRED_SERIES]
    AFTER INSERT,UPDATE,DELETE
AS
BEGIN
    UPDATE [dbo].[PBI_STATS] SET
        [FREDCount] = (SELECT COUNT(*) FROM [dbo].[FRED_SERIES])
        ,[FREDActive] = (SELECT COUNT(*) FROM [dbo].[FRED_SERIES] WHERE [IsActive] = 1)
        ,[FREDInactive] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[FRED_SERIES] WHERE [IsActive] = 0)
END
GO

CREATE TRIGGER [dbo].[trg_MarketIndex_IUD] ON [dbo].[MARKET_INDEX]
    AFTER INSERT,UPDATE,DELETE
AS
BEGIN
    UPDATE [dbo].[PBI_STATS] SET
        [MarketIdxCount] = (SELECT COUNT(*) FROM [dbo].[MARKET_INDEX])
END
GO