USING [FINDATA]
GO

CREATE TRIGGER [dbo].[trg_Stock_IUD] ON [dbo].[STOCK]
    AFTER INSERT,UPDATE,DELETE
    UPDATE [dbo].[PBI_STATS] SET
        [SymCount] = (SELECT COUNT(*) FROM [dbo].[STOCK])
        ,[SymActive] = (SELECT COUNT(*) FROM [dbo].[STOCK] WHERE [IsActive] = 1)
        ,[SymInactive] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [IsActive] = 0)
        ,[SymOptions] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [HasOptions] = 1)
        ,[SymDividends] = (SELECT COUNT(*) FROM [FINDATA].[dbo].[STOCK] WHERE [HasDividend] = 1)
GO