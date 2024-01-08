USE [FINDATA]
GO

-- CREATE TABLE [dbo].[INSTRUMENT_TYPE] (
--     [TypeID] TINYINT IDENTITY(1,1) NOT NULL
--     ,[TypeShortName] VARCHAR(10) NOT NULL
--     ,[TypeName] VARCHAR(30) NOT NULL

--     CONSTRAINT [PK_INSTRUMENT_TYPE] PRIMARY KEY CLUSTERED ([TypeID] ASC)
-- )
-- GO

CREATE TABLE [dbo].[PBI_STATS] (
    [StatsID] INT IDENTITY(1,1) NOT NULL
    ,[SymCount] INT NOT NULL
    ,[SymActive] INT NOT NULL
    ,[SymInactive] INT NOT NULL
    ,[SymOptions] INT NOT NULL
    ,[SymDividends] INT NOT NULL
    ,[FREDCount] INT NOT NULL
    ,[FREDActive] INT NOT NULL
    ,[FREDInactive] INT NOT NULL
    ,[MarketIdxCount] SMALLINT NOT NULL

    CONSTRAINT [PK_PBI_STATS] PRIMARY KEY ([StatsID])
    ,CONSTRAINT [CK_PBI_STATS] CHECK ([StatsID] = 1)
)
GO

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

CREATE TABLE [dbo].[SEC_FILING_FORM] (
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
GO

CREATE TABLE [dbo].[MARKET_INDEX_HISTORY] (
    [IndexID] TINYINT NOT NULL
    ,[TradingDate] DATE NOT NULL
    ,[OpenPrice] DECIMAL(17,4) NULL
	,[HighPrice] DECIMAL(17,4) NULL
	,[LowPrice] DECIMAL(17,4) NULL
	,[ClosePrice] DECIMAL(17,4) NULL
	,[AdjClosePrice] DECIMAL(17,4) NULL
	,[Volume] BIGINT NULL
    
    CONSTRAINT [PK_MARKET_INDEX_HISTORY] PRIMARY KEY CLUSTERED ([IndexID] ASC,[TradingDate] DESC)
    ,CONSTRAINT [FK_MARKET_INDEX_HISTORY_IndexID] FOREIGN KEY ([IndexID]) REFERENCES [MARKET_INDEX]([IndexID])
)
    WITH (DATA_COMPRESSION = ROW)
GO

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

CREATE TABLE [dbo].[STOCK_STATS] (
    [StockID] INT NOT NULL
    ,[StatsDate] DATE NOT NULL
    ,[MarketCap] BIGINT NOT NULL -- [INCOME_STATEMENT].[DilutedAverageShares] * [PRICE_HISTORY].[ClosePrice] WHERE [PriceDate] = [INCOME_STATEMENT].[ReportDate]
    ,[EnterpriseValue] BIGINT NOT NULL -- [STOCK_STATS].[MarketCap] + [BALANCE_SHEET].[TotalDebt] - [BALANCE_SHEET].[CashCashEquivalentsAndShortTermInvestments]
    ,[Prive_Earnings_Ratio] DECIMAL(9,4) NOT NULL -- TOP 1 [PRICE_HISTORY].[ClosePrice] (ORDER BY [PriceDate] DESC) / [INCOME_STATEMENT].[DilutedEPS]
    ,[Price_Sales_Ratio] DECIMAL(9,4) NOT NULL -- [STOCK_STATS].[MarketCap] / [INCOME_STATEMENT].[OperatingRevenue] (Last 4 Quarters)
    ,[BookValuePerShare] DECIMAL(9,4) -- = [BALANCE_SHEET].[CommonStockEquity] / [INCOME_STATEMENT].[DilutedAverageShares]
    ,[EarningsPerShare] DECIMAL(9,2) NOT NULL -- [INCOME_STATEMENT].[BasicEPS]
    ,[DilutedEarningsPerShare] DECIMAL(9,2) NOT NULL -- [INCOME_STATEMENT].[DilutedEPS]
    ,[Price_Book_Ratio] DECIMAL(9,4) NOT NULL -- [STOCK_STATS].[MarketCap] / [BALANCE_SHEET].[ShareholdersEquity]
    ,[Price_FreeCashFlow_Ratio] DECIMAL(9,4) NOT NULL -- [STOCK_STATS].[MarketCap] / [CASH_FLOW].[FreeCashFlow]
    ,[Price_OpCashFlow_Ratio] DECIMAL(9,4) NOT NULL -- [STOCK_STATS].[MarketCap] / [CASH_FLOW].[OperatingCashFlow]
    ,[CurrentRatio] DECIMAL(9,4) NOT NULL -- [BALANCE_SHEET].[CurrentAssets] / [BALANCE_SHEET].[CurrentLiabilities]

    CONSTRAINT [PK_STOCK_STATS] PRIMARY KEY CLUSTERED ([StockID] ASC,[StatsDate] DESC)
)
GO

CREATE TABLE [dbo].[EARNINGS_CALENDAR] (
    [StockID] INT NOT NULL
    ,[Scheduled] DATETIME2(0) NOT NULL
    ,[EPSEstimate] DECIMAL(8,2) NULL

    CONSTRAINT [PK_STOCK_PRICE_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[Scheduled] DESC)
)
GO

CREATE TABLE [dbo].[SPLIT_CALENDAR] (
    [StockID] INT NOT NULL
    ,[SplitDate] DATETIME2(0) NOT NULL
    ,[SplitRatio] VARCHAR(24) NOT NULL
    ,[SplitFactor] DECIMAL(20,16)

    CONSTRAINT [PK_STOCK_PRICE_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[Scheduled] DESC)
)
GO

CREATE TABLE [dbo].[SEC_FILING_INDEX] (
    [StockID] INT NOT NULL
    ,[DateFiled] DATE NOT NULL
    ,[FormID] SMALLINT NOT NULL
    ,[FileName] VARCHAR(45) NOT NULL

    CONSTRAINT [PK_SEC_FILING_INDEX] PRIMARY KEY CLUSTERED ([StockID] ASC,[DateFiled] DESC,[FormID],[FileName] ASC)
    ,CONSTRAINT [FK_SEC_FILING_INDEX_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
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
	,[SplitRatio] VARCHAR(24) NOT NULL

	CONSTRAINT [PK_STOCK_SPLIT_HISTORY] PRIMARY KEY CLUSTERED ([StockID] ASC,[SplitDate] DESC)
	,CONSTRAINT [FK_STOCK_SPLIT_HISTORY_StockID] FOREIGN KEY ([StockID]) REFERENCES [STOCK]([StockID]) ON DELETE CASCADE
)
GO

CREATE TABLE [dbo].[INCOME_STATEMENT] (
    [StockID] INT NOT NULL
    ,[ReportDate] DATE NOT NULL
    ,[OperatingRevenue] BIGINT NULL
    ,[ExciseTaxes] BIGINT NULL
    ,[TotalRevenue] BIGINT NULL
    ,[CostOfRevenue] BIGINT NULL
    ,[GrossProfit] BIGINT NULL
    ,[SalariesAndWages] BIGINT NULL
    ,[RentAndLandingFees] BIGINT NULL
    ,[InsuranceAndClaims] BIGINT NULL
    ,[OtherGandA] BIGINT NULL
    ,[GeneralAndAdministrativeExpense] BIGINT NULL
    ,[SellingAndMarketingExpense] BIGINT NULL
    ,[SellingGeneralAndAdministration] BIGINT NULL
    ,[ResearchAndDevelopment] BIGINT NULL
    ,[DepreciationIncomeStatement] BIGINT NULL
    ,[AmortizationOfIntangiblesIncomeStatement] BIGINT NULL
    ,[Amortization] BIGINT NULL
    ,[DepreciationAndAmortizationInIncomeStatement] BIGINT NULL
    ,[DepletionIncomeStatement] BIGINT NULL
    ,[DepreciationAmortizationDepletionIncomeStatement] BIGINT NULL
    ,[ProvisionForDoubtfulAccounts] BIGINT NULL
    ,[OtherTaxes] BIGINT NULL
    ,[OtherOperatingExpenses] BIGINT NULL
    ,[OperatingExpense] BIGINT NULL
    ,[OperatingIncome] BIGINT NULL
    ,[InterestIncomeNonOperating] BIGINT NULL
    ,[InterestExpenseNonOperating] BIGINT NULL
    ,[TotalOtherFinanceCost] BIGINT NULL
    ,[NetNonOperatingInterestIncomeExpense] BIGINT NULL
    ,[GainOnSaleOfSecurity] BIGINT NULL
    ,[EarningsFromEquityInterest] BIGINT NULL
    ,[SecuritiesAmortization] BIGINT NULL
    ,[RestructuringAndMergernAcquisition] BIGINT NULL
    ,[ImpairmentOfCapitalAssets] BIGINT NULL
    ,[WriteOff] BIGINT NULL
    ,[OtherSpecialCharges] BIGINT NULL
    ,[GainOnSaleOfBusiness] BIGINT NULL
    ,[GainOnSaleOfPPE] BIGINT NULL
    ,[SpecialIncomeCharges] BIGINT NULL
    ,[OtherNonOperatingIncomeExpenses] BIGINT NULL
    ,[OtherIncomeExpense] BIGINT NULL
    ,[PretaxIncome] BIGINT NULL
    ,[TaxProvision] BIGINT NULL
    ,[EarningsFromEquityInterestNetOfTax] BIGINT NULL
    ,[NetIncomeContinuousOperations] BIGINT NULL
    ,[NetIncomeDiscontinuousOperations] BIGINT NULL
    ,[NetIncomeExtraordinary] BIGINT NULL
    ,[NetIncomeFromTaxLossCarryforward] BIGINT NULL
    ,[NetIncomeIncludingNoncontrollingInterests] BIGINT NULL
    ,[MinorityInterests] BIGINT NULL
    ,[NetIncome] BIGINT NULL
    ,[PreferredStockDividends] BIGINT NULL
    ,[OtherunderPreferredStockDividend] BIGINT NULL
    ,[NetIncomeCommonStockholders] BIGINT NULL
    ,[AverageDilutionEarnings] BIGINT NULL
    ,[DilutedNIAvailtoComStockholders] BIGINT NULL
    ,[BasicContinuousOperations] BIGINT NULL
    ,[BasicDiscontinuousOperations] BIGINT NULL
    ,[BasicExtraordinary] BIGINT NULL
    ,[BasicAccountingChange] BIGINT NULL
    ,[TaxLossCarryforwardBasicEPS] BIGINT NULL
    ,[BasicEPSOtherGainsLosses] BIGINT NULL
    ,[BasicEPS] DECIMAL(9,2) NULL
    ,[DilutedContinuousOperations] BIGINT NULL
    ,[DilutedDiscontinuousOperations] BIGINT NULL
    ,[DilutedExtraordinary] BIGINT NULL
    ,[DilutedAccountingChange] BIGINT NULL
    ,[TaxLossCarryforwardDilutedEPS] BIGINT NULL
    ,[DilutedEPSOtherGainsLosses] BIGINT NULL
    ,[DilutedEPS] DECIMAL(9,2) NULL
    ,[BasicAverageShares] BIGINT NULL
    ,[DilutedAverageShares] BIGINT NULL
    ,[DividendPerShare] DECIMAL(9,4) NULL
    ,[TotalOperatingIncomeAsReported] BIGINT NULL
    ,[ReportedNormalizedBasicEPS] BIGINT NULL
    ,[ReportedNormalizedDilutedEPS] BIGINT NULL
    ,[RentExpenseSupplemental] BIGINT NULL
    ,[TotalExpenses] BIGINT NULL
    ,[NetIncomeFromContinuingAndDiscontinuedOperation] BIGINT NULL
    ,[NormalizedIncome] BIGINT NULL
    ,[ContinuingAndDiscontinuedBasicEPS] BIGINT NULL
    ,[ContinuingAndDiscontinuedDilutedEPS] BIGINT NULL
    ,[InterestIncome] BIGINT NULL
    ,[InterestExpense] BIGINT NULL
    ,[NetInterestIncome] BIGINT NULL
    ,[EBIT] BIGINT NULL
    ,[EBITDA] BIGINT NULL
    ,[ReconciledCostOfRevenue] BIGINT NULL
    ,[ReconciledDepreciation] BIGINT NULL
    ,[NetIncomeFromContinuingOperationNetMinorityInterest] BIGINT NULL
    ,[TotalUnusualItemsExcludingGoodwill] BIGINT NULL
    ,[TotalUnusualItems] BIGINT NULL
    ,[NormalizedBasicEPS] DECIMAL(9,2) NULL
    ,[NormalizedDilutedEPS] DECIMAL(9,2) NULL
    ,[NormalizedEBITDA] BIGINT NULL
    ,[TaxRateForCalcs] DECIMAL(7,6) NULL
    ,[TaxEffectOfUnusualItems] BIGINT NULL

    CONSTRAINT [PK_INCOME_STATEMENT] PRIMARY KEY CLUSTERED ([StockID] ASC,[ReportDate] DESC)
)
    WITH (DATA_COMPRESSION = ROW)
GO

CREATE TABLE [dbo].[BALANCE_SHEET] (
    [StockID] INT NOT NULL
    ,[ReportDate] DATE NOT NULL
    ,[CashFinancial] BIGINT NULL
    ,[CashEquivalents] BIGINT NULL
    ,[CashAndCashEquivalents] BIGINT NULL
    ,[OtherShortTermInvestments] BIGINT NULL
    ,[CashCashEquivalentsAndShortTermInvestments] BIGINT NULL
    ,[GrossAccountsReceivable] BIGINT NULL
    ,[AllowanceForDoubtfulAccountsReceivable] BIGINT NULL
    ,[AccountsReceivable] BIGINT NULL
    ,[LoansReceivable] BIGINT NULL
    ,[NotesReceivable] BIGINT NULL
    ,[AccruedInterestReceivable] BIGINT NULL
    ,[TaxesReceivable] BIGINT NULL
    ,[DuefromRelatedPartiesCurrent] BIGINT NULL
    ,[OtherReceivables] BIGINT NULL
    ,[ReceivablesAdjustmentsAllowances] BIGINT NULL
    ,[Receivables] BIGINT NULL
    ,[RawMaterials] BIGINT NULL
    ,[WorkInProcess] BIGINT NULL
    ,[FinishedGoods] BIGINT NULL
    ,[OtherInventories] BIGINT NULL
    ,[InventoriesAdjustmentsAllowances] BIGINT NULL
    ,[Inventory] BIGINT NULL
    ,[PrepaidAssets] BIGINT NULL
    ,[RestrictedCash] BIGINT NULL
    ,[CurrentDeferredTaxesAssets] BIGINT NULL
    ,[CurrentDeferredAssets] BIGINT NULL
    ,[AssetsHeldForSaleCurrent] BIGINT NULL
    ,[HedgingAssetsCurrent] BIGINT NULL
    ,[OtherCurrentAssets] BIGINT NULL
    ,[CurrentAssets] BIGINT NULL
    ,[Properties] BIGINT NULL
    ,[LandAndImprovements] BIGINT NULL
    ,[BuildingsAndImprovements] BIGINT NULL
    ,[MachineryFurnitureEquipment] BIGINT NULL
    ,[OtherProperties] BIGINT NULL
    ,[ConstructionInProgress] BIGINT NULL
    ,[Leases] BIGINT NULL
    ,[GrossPPE] BIGINT NULL
    ,[AccumulatedDepreciation] BIGINT NULL
    ,[NetPPE] BIGINT NULL
    ,[Goodwill] BIGINT NULL
    ,[OtherIntangibleAssets] BIGINT NULL
    ,[GoodwillAndOtherIntangibleAssets] BIGINT NULL
    ,[InvestmentProperties] BIGINT NULL
    ,[InvestmentsinSubsidiariesatCost] BIGINT NULL
    ,[InvestmentsinAssociatesatCost] BIGINT NULL
    ,[InvestmentsInOtherVenturesUnderEquityMethod] BIGINT NULL
    ,[InvestmentsinJointVenturesatCost] BIGINT NULL
    ,[LongTermEquityInvestment] BIGINT NULL
    ,[TradingSecurities] BIGINT NULL
    ,[FinancialAssetsDesignatedasFairValueThroughProfitorLossTotal] BIGINT NULL
    ,[AvailableForSaleSecurities] BIGINT NULL
    ,[HeldToMaturitySecurities] BIGINT NULL
    ,[InvestmentinFinancialAssets] BIGINT NULL
    ,[OtherInvestments] BIGINT NULL
    ,[InvestmentsAndAdvances] BIGINT NULL
    ,[FinancialAssets] BIGINT NULL
    ,[NonCurrentAccountsReceivable] BIGINT NULL
    ,[NonCurrentNoteReceivables] BIGINT NULL
    ,[DuefromRelatedPartiesNonCurrent] BIGINT NULL
    ,[NonCurrentDeferredTaxesAssets] BIGINT NULL
    ,[NonCurrentDeferredAssets] BIGINT NULL
    ,[NonCurrentPrepaidAssets] BIGINT NULL
    ,[DefinedPensionBenefit] BIGINT NULL
    ,[OtherNonCurrentAssets] BIGINT NULL
    ,[TotalNonCurrentAssets] BIGINT NULL
    ,[TotalAssets] BIGINT NULL
    ,[AccountsPayable] BIGINT NULL
    ,[IncomeTaxPayable] BIGINT NULL
    ,[TotalTaxPayable] BIGINT NULL
    ,[DividendsPayable] BIGINT NULL
    ,[DuetoRelatedPartiesCurrent] BIGINT NULL
    ,[OtherPayable] BIGINT NULL
    ,[Payables] BIGINT NULL
    ,[InterestPayable] BIGINT NULL
    ,[CurrentAccruedExpenses] BIGINT NULL
    ,[PayablesAndAccruedExpenses] BIGINT NULL
    ,[CurrentProvisions] BIGINT NULL
    ,[PensionandOtherPostRetirementBenefitPlansCurrent] BIGINT NULL
    ,[CurrentNotesPayable] BIGINT NULL
    ,[CommercialPaper] BIGINT NULL
    ,[LineOfCredit] BIGINT NULL
    ,[OtherCurrentBorrowings] BIGINT NULL
    ,[CurrentDebt] BIGINT NULL
    ,[CurrentCapitalLeaseObligation] BIGINT NULL
    ,[CurrentDebtAndCapitalLeaseObligation] BIGINT NULL
    ,[CurrentDeferredTaxesLiabilities] BIGINT NULL
    ,[CurrentDeferredRevenue] BIGINT NULL
    ,[CurrentDeferredLiabilities] BIGINT NULL
    ,[OtherCurrentLiabilities] BIGINT NULL
    ,[CurrentLiabilities] BIGINT NULL
    ,[LongTermProvisions] BIGINT NULL
    ,[LongTermDebt] BIGINT NULL
    ,[LongTermCapitalLeaseObligation] BIGINT NULL
    ,[LongTermDebtAndCapitalLeaseObligation] BIGINT NULL
    ,[NonCurrentDeferredTaxesLiabilities] BIGINT NULL
    ,[NonCurrentDeferredRevenue] BIGINT NULL
    ,[NonCurrentDeferredLiabilities] BIGINT NULL
    ,[TradeandOtherPayablesNonCurrent] BIGINT NULL
    ,[DuetoRelatedPartiesNonCurrent] BIGINT NULL
    ,[NonCurrentAccruedExpenses] BIGINT NULL
    ,[NonCurrentPensionAndOtherPostretirementBenefitPlans] BIGINT NULL
    ,[EmployeeBenefits] BIGINT NULL
    ,[DerivativeProductLiabilities] BIGINT NULL
    ,[PreferredSecuritiesOutsideStockEquity] BIGINT NULL
    ,[RestrictedCommonStock] BIGINT NULL
    ,[LiabilitiesHeldforSaleNonCurrent] BIGINT NULL
    ,[OtherNonCurrentLiabilities] BIGINT NULL
    ,[TotalNonCurrentLiabilitiesNetMinorityInterest] BIGINT NULL
    ,[TotalLiabilitiesNetMinorityInterest] BIGINT NULL
    ,[LimitedPartnershipCapital] BIGINT NULL
    ,[GeneralPartnershipCapital] BIGINT NULL
    ,[TotalPartnershipCapital] BIGINT NULL
    ,[PreferredStock] BIGINT NULL
    ,[CommonStock] BIGINT NULL
    ,[OtherCapitalStock] BIGINT NULL
    ,[CapitalStock] BIGINT NULL
    ,[AdditionalPaidInCapital] BIGINT NULL
    ,[RetainedEarnings] BIGINT NULL
    ,[TreasuryStock] BIGINT NULL
    ,[UnrealizedGainLoss] BIGINT NULL
    ,[MinimumPensionLiabilities] BIGINT NULL
    ,[ForeignCurrencyTranslationAdjustments] BIGINT NULL
    ,[FixedAssetsRevaluationReserve] BIGINT NULL
    ,[OtherEquityAdjustments] BIGINT NULL
    ,[GainsLossesNotAffectingRetainedEarnings] BIGINT NULL
    ,[OtherEquityInterest] BIGINT NULL
    ,[StockholdersEquity] BIGINT NULL
    ,[MinorityInterest] BIGINT NULL
    ,[TotalEquityGrossMinorityInterest] BIGINT NULL
    ,[TotalCapitalization] BIGINT NULL
    ,[PreferredStockEquity] BIGINT NULL
    ,[CommonStockEquity] BIGINT NULL
    ,[CapitalLeaseObligations] BIGINT NULL
    ,[NetTangibleAssets] BIGINT NULL
    ,[WorkingCapital] BIGINT NULL
    ,[InvestedCapital] BIGINT NULL
    ,[TangibleBookValue] BIGINT NULL
    ,[TotalDebt] BIGINT NULL
    ,[NetDebt] BIGINT NULL
    ,[ShareIssued] BIGINT NULL
    ,[OrdinarySharesNumber] BIGINT NULL
    ,[PreferredSharesNumber] BIGINT NULL

    CONSTRAINT [PK_BALANCE_SHEET] PRIMARY KEY CLUSTERED ([StockID] ASC,[ReportDate] DESC)
)
    WITH (DATA_COMPRESSION = ROW)
GO

CREATE TABLE [dbo].[CASH_FLOW] (
    [StockID] INT NOT NULL
    ,[ReportDate] DATE NOT NULL
    ,[DomesticSales] BIGINT NULL
    ,[AdjustedGeographySegmentData] BIGINT NULL
    ,[FreeCashFlow] BIGINT NULL
    ,[RepurchaseOfCapitalStock] BIGINT NULL
    ,[RepaymentOfDebt] BIGINT NULL
    ,[IssuanceOfDebt] BIGINT NULL
    ,[IssuanceOfCapitalStock] BIGINT NULL
    ,[CapitalExpenditure] BIGINT NULL
    ,[InterestPaidSupplementalData] BIGINT NULL
    ,[IncomeTaxPaidSupplementalData] BIGINT NULL
    ,[EndCashPosition] BIGINT NULL
    ,[OtherCashAdjustmentOutsideChangeinCash] BIGINT NULL
    ,[BeginningCashPosition] BIGINT NULL
    ,[EffectOfExchangeRateChanges] BIGINT NULL
    ,[ChangesInCash] BIGINT NULL
    ,[OtherCashAdjustmentInsideChangeinCash] BIGINT NULL
    ,[CashFlowFromDiscontinuedOperation] BIGINT NULL
    ,[FinancingCashFlow] BIGINT NULL
    ,[CashFromDiscontinuedFinancingActivities] BIGINT NULL
    ,[CashFlowFromContinuingFinancingActivities] BIGINT NULL
    ,[NetOtherFinancingCharges] BIGINT NULL
    ,[InterestPaidCFF] BIGINT NULL
    ,[ProceedsFromStockOptionExercised] BIGINT NULL
    ,[CashDividendsPaid] BIGINT NULL
    ,[PreferredStockDividendPaid] BIGINT NULL
    ,[CommonStockDividendPaid] BIGINT NULL
    ,[NetPreferredStockIssuance] BIGINT NULL
    ,[PreferredStockPayments] BIGINT NULL
    ,[PreferredStockIssuance] BIGINT NULL
    ,[NetCommonStockIssuance] BIGINT NULL
    ,[CommonStockPayments] BIGINT NULL
    ,[CommonStockIssuance] BIGINT NULL
    ,[NetIssuancePaymentsOfDebt] BIGINT NULL
    ,[NetShortTermDebtIssuance] BIGINT NULL
    ,[ShortTermDebtPayments] BIGINT NULL
    ,[ShortTermDebtIssuance] BIGINT NULL
    ,[NetLongTermDebtIssuance] BIGINT NULL
    ,[LongTermDebtPayments] BIGINT NULL
    ,[LongTermDebtIssuance] BIGINT NULL
    ,[InvestingCashFlow] BIGINT NULL
    ,[CashFromDiscontinuedInvestingActivities] BIGINT NULL
    ,[CashFlowFromContinuingInvestingActivities] BIGINT NULL
    ,[NetOtherInvestingChanges] BIGINT NULL
    ,[InterestReceivedCFI] BIGINT NULL
    ,[DividendsReceivedCFI] BIGINT NULL
    ,[NetInvestmentPurchaseAndSale] BIGINT NULL
    ,[SaleOfInvestment] BIGINT NULL
    ,[PurchaseOfInvestment] BIGINT NULL
    ,[NetInvestmentPropertiesPurchaseAndSale] BIGINT NULL
    ,[SaleOfInvestmentProperties] BIGINT NULL
    ,[PurchaseOfInvestmentProperties] BIGINT NULL
    ,[NetBusinessPurchaseAndSale] BIGINT NULL
    ,[SaleOfBusiness] BIGINT NULL
    ,[PurchaseOfBusiness] BIGINT NULL
    ,[NetIntangiblesPurchaseAndSale] BIGINT NULL
    ,[SaleOfIntangibles] BIGINT NULL
    ,[PurchaseOfIntangibles] BIGINT NULL
    ,[NetPPEPurchaseAndSale] BIGINT NULL
    ,[SaleOfPPE] BIGINT NULL
    ,[PurchaseOfPPE] BIGINT NULL
    ,[CapitalExpenditureReported] BIGINT NULL
    ,[OperatingCashFlow] BIGINT NULL
    ,[CashFromDiscontinuedOperatingActivities] BIGINT NULL
    ,[CashFlowFromContinuingOperatingActivities] BIGINT NULL
    ,[TaxesRefundPaid] BIGINT NULL
    ,[InterestReceivedCFO] BIGINT NULL
    ,[InterestPaidCFO] BIGINT NULL
    ,[DividendReceivedCFO] BIGINT NULL
    ,[DividendPaidCFO] BIGINT NULL
    ,[ChangeInWorkingCapital] BIGINT NULL
    ,[ChangeInOtherWorkingCapital] BIGINT NULL
    ,[ChangeInOtherCurrentLiabilities] BIGINT NULL
    ,[ChangeInOtherCurrentAssets] BIGINT NULL
    ,[ChangeInPayablesAndAccruedExpense] BIGINT NULL
    ,[ChangeInAccruedExpense] BIGINT NULL
    ,[ChangeInInterestPayable] BIGINT NULL
    ,[ChangeInPayable] BIGINT NULL
    ,[ChangeInDividendPayable] BIGINT NULL
    ,[ChangeInAccountPayable] BIGINT NULL
    ,[ChangeInTaxPayable] BIGINT NULL
    ,[ChangeInIncomeTaxPayable] BIGINT NULL
    ,[ChangeInPrepaidAssets] BIGINT NULL
    ,[ChangeInInventory] BIGINT NULL
    ,[ChangeInReceivables] BIGINT NULL
    ,[ChangesInAccountReceivables] BIGINT NULL
    ,[OtherNonCashItems] BIGINT NULL
    ,[ExcessTaxBenefitFromStockBasedCompensation] BIGINT NULL
    ,[StockBasedCompensation] BIGINT NULL
    ,[UnrealizedGainLossOnInvestmentSecurities] BIGINT NULL
    ,[ProvisionandWriteOffofAssets] BIGINT NULL
    ,[AssetImpairmentCharge] BIGINT NULL
    ,[AmortizationOfSecurities] BIGINT NULL
    ,[DeferredTax] BIGINT NULL
    ,[DeferredIncomeTax] BIGINT NULL
    ,[DepreciationAmortizationDepletion] BIGINT NULL
    ,[Depletion] BIGINT NULL
    ,[DepreciationAndAmortization] BIGINT NULL
    ,[AmortizationCashFlow] BIGINT NULL
    ,[AmortizationOfIntangibles] BIGINT NULL
    ,[Depreciation] BIGINT NULL
    ,[OperatingGainsLosses] BIGINT NULL
    ,[PensionAndEmployeeBenefitExpense] BIGINT NULL
    ,[EarningsLossesFromEquityInvestments] BIGINT NULL
    ,[GainLossOnInvestmentSecurities] BIGINT NULL
    ,[NetForeignCurrencyExchangeGainLoss] BIGINT NULL
    ,[GainLossOnSaleOfPPE] BIGINT NULL
    ,[GainLossOnSaleOfBusiness] BIGINT NULL
    ,[NetIncomeFromContinuingOperations] BIGINT NULL
    ,[CashFlowsfromusedinOperatingActivitiesDirect] BIGINT NULL
    ,[TaxesRefundPaidDirect] BIGINT NULL
    ,[InterestReceivedDirect] BIGINT NULL
    ,[InterestPaidDirect] BIGINT NULL
    ,[DividendsReceivedDirect] BIGINT NULL
    ,[DividendsPaidDirect] BIGINT NULL
    ,[ClassesofCashPayments] BIGINT NULL
    ,[OtherCashPaymentsfromOperatingActivities] BIGINT NULL
    ,[PaymentsonBehalfofEmployees] BIGINT NULL
    ,[PaymentstoSuppliersforGoodsandServices] BIGINT NULL
    ,[ClassesofCashReceiptsfromOperatingActivities] BIGINT NULL
    ,[OtherCashReceiptsfromOperatingActivities] BIGINT NULL
    ,[ReceiptsfromGovernmentGrants] BIGINT NULL
    ,[ReceiptsfromCustomers] BIGINT NULL

    CONSTRAINT [PK_CASH_FLOW] PRIMARY KEY CLUSTERED ([StockID] ASC,[ReportDate] DESC)
)
    WITH (DATA_COMPRESSION = ROW)
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