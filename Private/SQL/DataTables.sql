USE [FINDATA]
GO

-- CREATE TABLE [dbo].[INSTRUMENT_TYPE] (
--     [TypeID] TINYINT IDENTITY(1,1) NOT NULL
--     ,[TypeShortName] VARCHAR(10) NOT NULL
--     ,[TypeName] VARCHAR(30) NOT NULL

--     CONSTRAINT [PK_INSTRUMENT_TYPE] PRIMARY KEY CLUSTERED ([TypeID] ASC)
-- )
-- GO

CREATE TABLE [dbo].[SIC_OFFICE] (
    [OfficeID] TINYINT IDENTITY(1,1) NOT NULL
    ,[OfficeName] VARCHAR(50) NOT NULL

    CONSTRAINT [PK_SIC_OFFICE] PRIMARY KEY CLUSTERED ([OfficeID] ASC)
    ,CONSTRAINT [UQ_SIC_OFFICE_Name] UNIQUE ([OfficeName])
)
GO

CREATE TABLE [dbo].[SIC] (
    [SICCode] SMALLINT NOT NULL
    ,[Description] VARCHAR(65) NOT NULL
    ,[OfficeID] TINYINT NULL

    CONSTRAINT [PK_SIC] PRIMARY KEY CLUSTERED ([SICCode] ASC)
    --,CONSTRAINT [UQ_SIC_Code] UNIQUE ([SICCode])
    ,CONSTRAINT [FK_SIC_Office] FOREIGN KEY ([OfficeID]) REFERENCES [SIC_OFFICE]([OfficeID]) ON DELETE SET NULL
)
GO

CREATE TABLE [dbo].[GICS] (
    [GicsID] SMALLINT IDENTITY(1,1) NOT NULL
    ,[GicsCode] VARCHAR(8) NULL
    ,[GicsNode] HIERARCHYID NULL
    ,[GicsLabel] VARCHAR(60) NULL

    CONSTRAINT [PK_GICS] PRIMARY KEY CLUSTERED ([GicsID] ASC)
	,CONSTRAINT [UQ_GICS_Node] UNIQUE ([GicsNode])
)
GO

CREATE TABLE [dbo].[COUNTRY] (
    [CountryID] SMALLINT IDENTITY(1,1) NOT NULL
    ,[CountryCode] CHAR(3) NOT NULL
    ,[CountryNode] HIERARCHYID NOT NULL
    ,[CountryName] VARCHAR(50) NOT NULL
    ,[Alpha2] CHAR(2) NULL
    ,[Alpha3] CHAR(3) NULL

    CONSTRAINT [PK_COUNTRY] PRIMARY KEY CLUSTERED ([CountryID] ASC)
    ,CONSTRAINT [UQ_COUNTRY_Node] UNIQUE ([CountryNode])
)
GO

CREATE TABLE [SEC_FILING_FORM] (
    [FormID] SMALLINT NOT NULL
    ,[FormType] VARCHAR(20) NOT NULL
    ,[FormDescription] VARCHAR(150) NULL

    CONSTRAINT [PK_SEC_FILING_FORM] PRIMARY KEY CLUSTERED ([FormID] ASC)
    ,CONSTRAINT [UQ_SEC_FILING_FORM] UNIQUE ([FormType])
)
GO

-- CREATE TABLE [dbo].[TIMEZONE] (
--     [TimeZoneID] TINYINT IDENTITY(1,1) NOT NULL
--     ,[DisplayName] VARCHAR(75) NOT NULL
--     ,[StandardName] VARCHAR(40) NOT NULL
--     ,[DaylightName] VARCHAR(40) NOT NULL
--     ,[BaseUTCOffset] DECIMAL(3,1) NOT NULL
--     ,[SupportsDST] BIT NOT NULL

--     CONSTRAINT [PK_TIMEZONE] PRIMARY KEY ([TimeZoneID] ASC)
--     ,CONSTRAINT [UQ_TIMEZONE_DisplayName] UNIQUE ([DisplayName])
-- )
-- GO

--------------------------------------------------------------------------------------------------------------------

CREATE TABLE [dbo].[EXCHANGE] (
    [ExchangeID] SMALLINT IDENTITY(1,1) NOT NULL
    ,[CountryID] SMALLINT NOT NULL
    ,[ExchangeMIC] CHAR(4) NOT NULL
    ,[ExchangeName] VARCHAR(100) NOT NULL
    ,[ExchangeAcronym] VARCHAR(30) NULL
    ,[ExchangeLEI] CHAR(20) NULL
    
    CONSTRAINT [PK_EXCHANGE] PRIMARY KEY CLUSTERED ([ExchangeID] ASC)
    ,CONSTRAINT [UQ_EXCHANGE_Mic] UNIQUE ([ExchangeMIC])
    ,CONSTRAINT [FK_EXCHANGE_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [COUNTRY]([CountryID]) ON UPDATE CASCADE
)
GO

CREATE TABLE [dbo].[MARKET_INDEX] (
    [IndexID] TINYINT IDENTITY(1,1)
    ,[IndexCode] VARCHAR(12) NOT NULL
    ,[IndexName] VARCHAR(60) NULL

    CONSTRAINT [PK_MARKET_INDEX] PRIMARY KEY CLUSTERED ([IndexID] ASC)
    ,CONSTRAINT [UQ_MARKET_INDEX_Code] UNIQUE ([IndexCode])
)

CREATE TABLE [dbo].[MARKET_INDEX_HISTORY] (
    [IndexID] TINYINT NOT NULL
    ,[TradingDate] DATE NOT NULL
    ,[OpenPrice] DECIMAL(17,4) NULL
	,[HighPrice] DECIMAL(17,4) NULL
	,[LowPrice] DECIMAL(17,4) NULL
	,[ClosePrice] DECIMAL(17,4) NULL
	,[AdjClosePrice] DECIMAL(17,4) NULL
	,[Volume] BIGINT NULL
    
    CONSTRAINT [PK_MARKET_INDEX_HISTORY] PRIMARY KEY CLUSTERED ([IndexID],[TradingDate] ASC)
    ,CONSTRAINT [FK_MARKET_INDEX_HISTORY_IndexID] FOREIGN KEY ([IndexID]) REFERENCES [MARKET_INDEX]([IndexID])
)

CREATE TABLE [dbo].[STOCK] (
	[StockID] INT IDENTITY(1,1)
	,[StockSymbol] VARCHAR(12) NOT NULL
	,[StockName] NVARCHAR(60) NULL
    ,[IsActive] BIT NOT NULL
    ,[ExchangeID] SMALLINT NULL
    ,[CUSIP] CHAR(9) NULL
    ,[CIK] CHAR(10) NULL
    ,[ISIN] CHAR(12) NULL
    ,[SIC] SMALLINT NULL
    ,[HasOptions] BIT NOT NULL
    ,[HasDividend] BIT NOT NULL
    ,[GICS] HIERARCHYID NULL
    ,[Created] DATETIME2(0) NOT NULL
	,[Updated] DATETIME2(0) NOT NULL

	CONSTRAINT [PK_STOCK] PRIMARY KEY CLUSTERED ([StockID] ASC)
	,CONSTRAINT [UQ_STOCK_StockSymbol] UNIQUE ([StockSymbol])
    --,CONSTRAINT [UQ_STOCK_Cik] UNIQUE ([CIK])
    ,CONSTRAINT [FK_STOCK_Sic] FOREIGN KEY ([SIC]) REFERENCES [SIC]([SICCode]) ON UPDATE CASCADE ON DELETE SET NULL
    ,CONSTRAINT [FK_STOCK_Exchange] FOREIGN KEY ([ExchangeID]) REFERENCES [EXCHANGE]([ExchangeID]) ON UPDATE CASCADE ON DELETE SET NULL
)
GO

-- CREATE TABLE [dbo].[STOCK_STATS] (
--     [StockID] INT NOT NULL
    
-- )

CREATE TABLE [SEC_FILING_INDEX] (
    [StockID] INT NOT NULL
    ,[DateFiled] DATE NOT NULL
    ,[FormID] SMALLINT NOT NULL
    ,[FileName] VARCHAR(45) NOT NULL

    CONSTRAINT [PK_SEC_FILING_INDEX] PRIMARY KEY CLUSTERED ([StockID] ASC,[DateFiled] DESC,[FormID],[FileName] ASC)
    ,CONSTRAINT [FK_SEC_FILING_INDEX_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID])
    ,CONSTRAINT [FK_SEC_FILING_INDEX_FormID] FOREIGN KEY ([FormID]) REFERENCES [SEC_FILING_FORM]([FormID])
)
GO

CREATE TABLE [dbo].[PRICE_HISTORY] (
	[StockID] INT NOT NULL
	,[PriceDate] DATE NOT NULL
	,[OpenPrice] DECIMAL(17,4) NULL
	,[HighPrice] DECIMAL(17,4) NULL
	,[LowPrice] DECIMAL(17,4) NULL
	,[ClosePrice] DECIMAL(17,4) NULL
	,[AdjClosePrice] DECIMAL(17,4) NULL
	,[Volume] BIGINT NULL

	CONSTRAINT [PK_STOCK_PRICE_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[PriceDate] DESC)
	,CONSTRAINT [FK_STOCK_PRICE_HISTORY_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
)
	WITH (DATA_COMPRESSION = PAGE)
GO

CREATE TABLE [dbo].[DIVIDEND_HISTORY] (
	[StockID] INT NOT NULL
	,[DividendDate] DATE NOT NULL
	,[DividendAmount] DECIMAL(8,4) NOT NULL

	CONSTRAINT [PK_STOCK_DIVIDEND_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[DividendDate] DESC)
	,CONSTRAINT [FK_STOCK_DIVIDEND_HISTORY_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[SPLIT_HISTORY] (
	[StockID] INT NOT NULL
	,[SplitDate] DATE NOT NULL
	,[SplitRatio] VARCHAR(20) NOT NULL

	CONSTRAINT [PK_STOCK_SPLIT_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[SplitDate] DESC)
	,CONSTRAINT [FK_STOCK_SPLIT_HISTORY_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[INCOME_STATEMENT] (
    [StockID] INT NOT NULL
    ,[ReportDate] DATE NOT NULL
    ,[TaxEffectOfUnusualItems] BIGINT NULL
    ,[TaxRateForCalcs] BIGINT NULL
    ,[NormalizedEBITDA] BIGINT NULL
    ,[NormalizedDilutedEPS] BIGINT NULL
    ,[NormalizedBasicEPS] BIGINT NULL
    ,[TotalUnusualItems] BIGINT NULL
    ,[TotalUnusualItemsExcludingGoodwill] BIGINT NULL
    ,[NetIncomeFromContinuingOperationNetMinorityInterest] BIGINT NULL
    ,[ReconciledDepreciation] BIGINT NULL
    ,[ReconciledCostOfRevenue] BIGINT NULL
    ,[EBITDA] BIGINT NULL
    ,[EBIT] BIGINT NULL
    ,[NetInterestIncome] BIGINT NULL
    ,[InterestExpense] BIGINT NULL
    ,[InterestIncome] BIGINT NULL
    ,[ContinuingAndDiscontinuedDilutedEPS] BIGINT NULL
    ,[ContinuingAndDiscontinuedBasicEPS] BIGINT NULL
    ,[NormalizedIncome] BIGINT NULL
    ,[NetIncomeFromContinuingAndDiscontinuedOperation] BIGINT NULL
    ,[TotalExpenses] BIGINT NULL
    ,[RentExpenseSupplemental] BIGINT NULL
    ,[ReportedNormalizedDilutedEPS] BIGINT NULL
    ,[ReportedNormalizedBasicEPS] BIGINT NULL
    ,[TotalOperatingIncomeAsReported] BIGINT NULL
    ,[DividendPerShare] BIGINT NULL
    ,[DilutedAverageShares] BIGINT NULL
    ,[BasicAverageShares] BIGINT NULL
    ,[DilutedEPS] BIGINT NULL
    ,[DilutedEPSOtherGainsLosses] BIGINT NULL
    ,[TaxLossCarryforwardDilutedEPS] BIGINT NULL
    ,[DilutedAccountingChange] BIGINT NULL
    ,[DilutedExtraordinary] BIGINT NULL
    ,[DilutedDiscontinuousOperations] BIGINT NULL
    ,[DilutedContinuousOperations] BIGINT NULL
    ,[BasicEPS] BIGINT NULL
    ,[BasicEPSOtherGainsLosses] BIGINT NULL
    ,[TaxLossCarryforwardBasicEPS] BIGINT NULL
    ,[BasicAccountingChange] BIGINT NULL
    ,[BasicExtraordinary] BIGINT NULL
    ,[BasicDiscontinuousOperations] BIGINT NULL
    ,[BasicContinuousOperations] BIGINT NULL
    ,[DilutedNIAvailtoComStockholders] BIGINT NULL
    ,[AverageDilutionEarnings] BIGINT NULL
    ,[NetIncomeCommonStockholders] BIGINT NULL
    ,[OtherunderPreferredStockDividend] BIGINT NULL
    ,[PreferredStockDividends] BIGINT NULL
    ,[NetIncome] BIGINT NULL
    ,[MinorityInterests] BIGINT NULL
    ,[NetIncomeIncludingNoncontrollingInterests] BIGINT NULL
    ,[NetIncomeFromTaxLossCarryforward] BIGINT NULL
    ,[NetIncomeExtraordinary] BIGINT NULL
    ,[NetIncomeDiscontinuousOperations] BIGINT NULL
    ,[NetIncomeContinuousOperations] BIGINT NULL
    ,[EarningsFromEquityInterestNetOfTax] BIGINT NULL
    ,[TaxProvision] BIGINT NULL
    ,[PretaxIncome] BIGINT NULL
    ,[OtherIncomeExpense] BIGINT NULL
    ,[OtherNonOperatingIncomeExpenses] BIGINT NULL
    ,[SpecialIncomeCharges] BIGINT NULL
    ,[GainOnSaleOfPPE] BIGINT NULL
    ,[GainOnSaleOfBusiness] BIGINT NULL
    ,[OtherSpecialCharges] BIGINT NULL
    ,[WriteOff] BIGINT NULL
    ,[ImpairmentOfCapitalAssets] BIGINT NULL
    ,[RestructuringAndMergernAcquisition] BIGINT NULL
    ,[SecuritiesAmortization] BIGINT NULL
    ,[EarningsFromEquityInterest] BIGINT NULL
    ,[GainOnSaleOfSecurity] BIGINT NULL
    ,[NetNonOperatingInterestIncomeExpense] BIGINT NULL
    ,[TotalOtherFinanceCost] BIGINT NULL
    ,[InterestExpenseNonOperating] BIGINT NULL
    ,[InterestIncomeNonOperating] BIGINT NULL
    ,[OperatingIncome] BIGINT NULL
    ,[OperatingExpense] BIGINT NULL
    ,[OtherOperatingExpenses] BIGINT NULL
    ,[OtherTaxes] BIGINT NULL
    ,[ProvisionForDoubtfulAccounts] BIGINT NULL
    ,[DepreciationAmortizationDepletionIncomeStatement] BIGINT NULL
    ,[DepletionIncomeStatement] BIGINT NULL
    ,[DepreciationAndAmortizationInIncomeStatement] BIGINT NULL
    ,[Amortization] BIGINT NULL
    ,[AmortizationOfIntangiblesIncomeStatement] BIGINT NULL
    ,[DepreciationIncomeStatement] BIGINT NULL
    ,[ResearchAndDevelopment] BIGINT NULL
    ,[SellingGeneralAndAdministration] BIGINT NULL
    ,[SellingAndMarketingExpense] BIGINT NULL
    ,[GeneralAndAdministrativeExpense] BIGINT NULL
    ,[OtherGandA] BIGINT NULL
    ,[InsuranceAndClaims] BIGINT NULL
    ,[RentAndLandingFees] BIGINT NULL
    ,[SalariesAndWages] BIGINT NULL
    ,[GrossProfit] BIGINT NULL
    ,[CostOfRevenue] BIGINT NULL
    ,[TotalRevenue] BIGINT NULL
    ,[ExciseTaxes] BIGINT NULL
    ,[OperatingRevenue] BIGINT NULL

    CONSTRAINT [PK_INCOME_STATEMENT] PRIMARY KEY CLUSTERED ([StockID] ASC,[ReportDate] DESC)
)
    WITH (DATA_COMPRESSION = PAGE)
GO
    


CREATE TABLE [dbo].[SHORT_INTEREST] (
    [StockID] INT NOT NULL
    ,[SettlementDate] DATE NOT NULL
    ,[DaysToCover] DECIMAL(5,2) NOT NULL
    ,[AvgDailyVolume] BIGINT NOT NULL
    ,[CurrentShortQty] BIGINT NOT NULL
    ,[PreviousShortQty] BIGINT NOT NULL
    ,[ChangePercent] DECIMAL(13,2) NOT NULL
    ,[ChangeShortQty] BIGINT NOT NULL

    CONSTRAINT [PK_STOCK_SHORT_INTEREST] PRIMARY KEY CLUSTERED ([StockID] ASC,[SettlementDate] DESC)
    ,CONSTRAINT [FK_STOCK_SHORT_INTEREST_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[FRED_CATEGORY] (
    [FredCatNode] HIERARCHYID NOT NULL
    ,[FredCatID] INT NOT NULL
    ,[FredCatName] VARCHAR(100) NOT NULL
    ,[Added] DATETIME2(0) NOT NULL

    CONSTRAINT [PK_FRED_CAT] PRIMARY KEY CLUSTERED ([FredCatNode],[FredCatID] ASC)
    ,CONSTRAINT [UQ_FRED_CAT_ID] UNIQUE ([FredCatID])
)
GO

CREATE TABLE [dbo].[FRED_SERIES_FREQUENCY] (
    [FredFreqID] TINYINT IDENTITY(1,1) NOT NULL
    ,[FredFreqLabel] VARCHAR(100)

    CONSTRAINT [PK_FRED_SERIES_FREQUENCY] PRIMARY KEY CLUSTERED ([FredFreqID])
)
GO

CREATE TABLE [dbo].[FRED_SERIES_UNIT] (
    [FredUnitID] SMALLINT IDENTITY(1,1) NOT NULL
    ,[FredUnitLabel] VARCHAR(100)

    CONSTRAINT [PK_FRED_SERIES_UNIT] PRIMARY KEY CLUSTERED ([FredUnitID])
)
GO

CREATE TABLE [dbo].[FRED_SERIES] (
    [FredSeries] INT IDENTITY(1,1) NOT NULL
    ,[FredSeriesID] VARCHAR(60) NOT NULL
    ,[FredCatID] INT NOT NULL
    ,[FredSeriesTitle] VARCHAR(120) NOT NULL
    ,[IsActive] BIT NOT NULL
    ,[ObserveStart] DATE NULL
    ,[ObserveEnd] DATE NULL
    ,[FredFreqID] TINYINT NULL
    ,[FredUnitID] SMALLINT NULL
    ,[SeasonalAdjusted] BIT NULL
    ,[LastRecord] DATE NULL
    ,[Added] DATETIME2(0) NOT NULL
    ,[LastPublished] DATETIME2(0) NOT NULL
    
    CONSTRAINT [PK_FRED_SERIES] PRIMARY KEY CLUSTERED ([FredSeries] ASC)
    ,CONSTRAINT [UQ_FRED_SERIES_ID] UNIQUE ([FredSeriesID])
    ,CONSTRAINT [FK_FRED_SERIES_Category] FOREIGN KEY ([FredCatID]) REFERENCES [FRED_CATEGORY]([FredCatID])
    ,CONSTRAINT [FK_FRED_SERIES_Frequency] FOREIGN KEY ([FredFreqID]) REFERENCES [FRED_SERIES_FREQUENCY]([FredFreqID])
    ,CONSTRAINT [FK_FRED_SERIES_Unit] FOREIGN KEY ([FredUnitID]) REFERENCES [FRED_SERIES_UNIT]([FredUnitID])
)
GO

CREATE TABLE [dbo].[FRED_HISTORY] (
    [FredSeriesID] INT NOT NULL
    ,[ReportDate] DATE NOT NULL
    ,[ReportValue] DECIMAL(19,4)

    CONSTRAINT [PK_FRED_HISTORY] PRIMARY KEY CLUSTERED ([FredSeriesID] ASC,[ReportDate] DESC)
    ,CONSTRAINT [FK_FRED_HISTORY_SeriesID] FOREIGN KEY ([FredSeriesID]) REFERENCES [FRED_SERIES]([FredSeries]) ON DELETE CASCADE
)
GO

