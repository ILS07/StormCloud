Function Get-StockFundamentalData
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)][String]$Symbol,
        [Parameter(Mandatory)]
            [ValidateSet("IncomeStatement","BalanceSheet","CashFlowStatement")][String[]]$Report
        # [Parameter()][ValidateSet("Quarter","Annual")]$Period = "Quarter"
    )

    BEGIN
    {
        [System.Collections.ArrayList]$output = @()
        $Symbol = $Symbol.Replace(".","-")

        $uriPrefix = `
            "https://query2.finance.yahoo.com/ws/fundamentals-timeseries/v1/finance/premium/timeseries/$Symbol`?lang=en-US&region=US&symbol=$Symbol`&padTimeSeries=true&type="
        $uriSuffix = "&merge=false&period1=&period2=1691511894&corsDomain=finance.yahoo.com"

        if ((Get-PSCallStack)[1].Command -eq "Add-StockFundamentalData")
        { $stockID = (Invoke-Sqlcmd @Script:db -Query "SELECT [StockID] FROM [dbo].[STOCK] WHERE [StockSymbol] = '$Symbol'").StockID }

        ### Forcing to "quarterly" for now.  Having "annual" as an option could lead to context mixing in the database.
        ### Annual and TTM values can be derived from the quarters in SQL or Power BI anyway, so may not worry about it.
        # $frequency = switch ($Period)
        # {
        #     "Quarter" { "quarterly" }
        #     "Annual" { "annual" }
        # }

        $frequency = "quarterly"

        $income = @(
            "OperatingRevenue"
            "ExciseTaxes"
            "TotalRevenue"
            "CostOfRevenue"
            "GrossProfit"
            "SalariesAndWages"
            "RentAndLandingFees"
            "InsuranceAndClaims"
            "OtherGandA"
            "GeneralAndAdministrativeExpense"
            "SellingAndMarketingExpense"
            "SellingGeneralAndAdministration"
            "ResearchAndDevelopment"
            "DepreciationIncomeStatement"
            "AmortizationOfIntangiblesIncomeStatement"
            "Amortization"
            "DepreciationAndAmortizationInIncomeStatement"
            "DepletionIncomeStatement"
            "DepreciationAmortizationDepletionIncomeStatement"
            "ProvisionForDoubtfulAccounts"
            "OtherTaxes"
            "OtherOperatingExpenses"
            "OperatingExpense"
            "OperatingIncome"
            "InterestIncomeNonOperating"
            "InterestExpenseNonOperating"
            "TotalOtherFinanceCost"
            "NetNonOperatingInterestIncomeExpense"
            "GainOnSaleOfSecurity"
            "EarningsFromEquityInterest"
            "SecuritiesAmortization"
            "RestructuringAndMergernAcquisition"
            "ImpairmentOfCapitalAssets"
            "WriteOff"
            "OtherSpecialCharges"
            "GainOnSaleOfBusiness"
            "GainOnSaleOfPPE"
            "SpecialIncomeCharges"
            "OtherNonOperatingIncomeExpenses"
            "OtherIncomeExpense"
            "PretaxIncome"
            "TaxProvision"
            "EarningsFromEquityInterestNetOfTax"
            "NetIncomeContinuousOperations"
            "NetIncomeDiscontinuousOperations"
            "NetIncomeExtraordinary"
            "NetIncomeFromTaxLossCarryforward"
            "NetIncomeIncludingNoncontrollingInterests"
            "MinorityInterests"
            "NetIncome"
            "PreferredStockDividends"
            "OtherunderPreferredStockDividend"
            "NetIncomeCommonStockholders"
            "AverageDilutionEarnings"
            "DilutedNIAvailtoComStockholders"
            "BasicContinuousOperations"
            "BasicDiscontinuousOperations"
            "BasicExtraordinary"
            "BasicAccountingChange"
            "TaxLossCarryforwardBasicEPS"
            "BasicEPSOtherGainsLosses"
            "BasicEPS"
            "DilutedContinuousOperations"
            "DilutedDiscontinuousOperations"
            "DilutedExtraordinary"
            "DilutedAccountingChange"
            "TaxLossCarryforwardDilutedEPS"
            "DilutedEPSOtherGainsLosses"
            "DilutedEPS"
            "BasicAverageShares"
            "DilutedAverageShares"
            "DividendPerShare"
            "TotalOperatingIncomeAsReported"
            "ReportedNormalizedBasicEPS"
            "ReportedNormalizedDilutedEPS"
            "RentExpenseSupplemental"
            "TotalExpenses"
            "NetIncomeFromContinuingAndDiscontinuedOperation"
            "NormalizedIncome"
            "ContinuingAndDiscontinuedBasicEPS"
            "ContinuingAndDiscontinuedDilutedEPS"
            "InterestIncome"
            "InterestExpense"
            "NetInterestIncome"
            "EBIT"
            "EBITDA"
            "ReconciledCostOfRevenue"
            "ReconciledDepreciation"
            "NetIncomeFromContinuingOperationNetMinorityInterest"
            "TotalUnusualItemsExcludingGoodwill"
            "TotalUnusualItems"
            "NormalizedBasicEPS"
            "NormalizedDilutedEPS"
            "NormalizedEBITDA"
            "TaxRateForCalcs"
            "TaxEffectOfUnusualItems"
        )

        $balance = @(
            "CashFinancial"
            "CashEquivalents"
            "CashAndCashEquivalents"
            "OtherShortTermInvestments"
            "CashCashEquivalentsAndShortTermInvestments"
            "GrossAccountsReceivable"
            "AllowanceForDoubtfulAccountsReceivable"
            "AccountsReceivable"
            "LoansReceivable"
            "NotesReceivable"
            "AccruedInterestReceivable"
            "TaxesReceivable"
            "DuefromRelatedPartiesCurrent"
            "OtherReceivables"
            "ReceivablesAdjustmentsAllowances"
            "Receivables"
            "RawMaterials"
            "WorkInProcess"
            "FinishedGoods"
            "OtherInventories"
            "InventoriesAdjustmentsAllowances"
            "Inventory"
            "PrepaidAssets"
            "RestrictedCash"
            "CurrentDeferredTaxesAssets"
            "CurrentDeferredAssets"
            "AssetsHeldForSaleCurrent"
            "HedgingAssetsCurrent"
            "OtherCurrentAssets"
            "CurrentAssets"
            "Properties"
            "LandAndImprovements"
            "BuildingsAndImprovements"
            "MachineryFurnitureEquipment"
            "OtherProperties"
            "ConstructionInProgress"
            "Leases"
            "GrossPPE"
            "AccumulatedDepreciation"
            "NetPPE"
            "Goodwill"
            "OtherIntangibleAssets"
            "GoodwillAndOtherIntangibleAssets"
            "InvestmentProperties"
            "InvestmentsinSubsidiariesatCost"
            "InvestmentsinAssociatesatCost"
            "InvestmentsInOtherVenturesUnderEquityMethod"
            "InvestmentsinJointVenturesatCost"
            "LongTermEquityInvestment"
            "TradingSecurities"
            "FinancialAssetsDesignatedasFairValueThroughProfitorLossTotal"
            "AvailableForSaleSecurities"
            "HeldToMaturitySecurities"
            "InvestmentinFinancialAssets"
            "OtherInvestments"
            "InvestmentsAndAdvances"
            "FinancialAssets"
            "NonCurrentAccountsReceivable"
            "NonCurrentNoteReceivables"
            "DuefromRelatedPartiesNonCurrent"
            "NonCurrentDeferredTaxesAssets"
            "NonCurrentDeferredAssets"
            "NonCurrentPrepaidAssets"
            "DefinedPensionBenefit"
            "OtherNonCurrentAssets"
            "TotalNonCurrentAssets"
            "TotalAssets"
            "AccountsPayable"
            "IncomeTaxPayable"
            "TotalTaxPayable"
            "DividendsPayable"
            "DuetoRelatedPartiesCurrent"
            "OtherPayable"
            "Payables"
            "InterestPayable"
            "CurrentAccruedExpenses"
            "PayablesAndAccruedExpenses"
            "CurrentProvisions"
            "PensionandOtherPostRetirementBenefitPlansCurrent"
            "CurrentNotesPayable"
            "CommercialPaper"
            "LineOfCredit"
            "OtherCurrentBorrowings"
            "CurrentDebt"
            "CurrentCapitalLeaseObligation"
            "CurrentDebtAndCapitalLeaseObligation"
            "CurrentDeferredTaxesLiabilities"
            "CurrentDeferredRevenue"
            "CurrentDeferredLiabilities"
            "OtherCurrentLiabilities"
            "CurrentLiabilities"
            "LongTermProvisions"
            "LongTermDebt"
            "LongTermCapitalLeaseObligation"
            "LongTermDebtAndCapitalLeaseObligation"
            "NonCurrentDeferredTaxesLiabilities"
            "NonCurrentDeferredRevenue"
            "NonCurrentDeferredLiabilities"
            "TradeandOtherPayablesNonCurrent"
            "DuetoRelatedPartiesNonCurrent"
            "NonCurrentAccruedExpenses"
            "NonCurrentPensionAndOtherPostretirementBenefitPlans"
            "EmployeeBenefits"
            "DerivativeProductLiabilities"
            "PreferredSecuritiesOutsideStockEquity"
            "RestrictedCommonStock"
            "LiabilitiesHeldforSaleNonCurrent"
            "OtherNonCurrentLiabilities"
            "TotalNonCurrentLiabilitiesNetMinorityInterest"
            "TotalLiabilitiesNetMinorityInterest"
            "LimitedPartnershipCapital"
            "GeneralPartnershipCapital"
            "TotalPartnershipCapital"
            "PreferredStock"
            "CommonStock"
            "OtherCapitalStock"
            "CapitalStock"
            "AdditionalPaidInCapital"
            "RetainedEarnings"
            "TreasuryStock"
            "UnrealizedGainLoss"
            "MinimumPensionLiabilities"
            "ForeignCurrencyTranslationAdjustments"
            "FixedAssetsRevaluationReserve"
            "OtherEquityAdjustments"
            "GainsLossesNotAffectingRetainedEarnings"
            "OtherEquityInterest"
            "StockholdersEquity"
            "MinorityInterest"
            "TotalEquityGrossMinorityInterest"
            "TotalCapitalization"
            "PreferredStockEquity"
            "CommonStockEquity"
            "CapitalLeaseObligations"
            "NetTangibleAssets"
            "WorkingCapital"
            "InvestedCapital"
            "TangibleBookValue"
            "TotalDebt"
            "NetDebt"
            "ShareIssued"
            "OrdinarySharesNumber"
            "PreferredSharesNumber"
        )

        $cash = @(
            "DomesticSales"
            "AdjustedGeographySegmentData"
            "FreeCashFlow"
            "RepurchaseOfCapitalStock"
            "RepaymentOfDebt"
            "IssuanceOfDebt"
            "IssuanceOfCapitalStock"
            "CapitalExpenditure"
            "InterestPaidSupplementalData"
            "IncomeTaxPaidSupplementalData"
            "EndCashPosition"
            "OtherCashAdjustmentOutsideChangeinCash"
            "BeginningCashPosition"
            "EffectOfExchangeRateChanges"
            "ChangesInCash"
            "OtherCashAdjustmentInsideChangeinCash"
            "CashFlowFromDiscontinuedOperation"
            "FinancingCashFlow"
            "CashFromDiscontinuedFinancingActivities"
            "CashFlowFromContinuingFinancingActivities"
            "NetOtherFinancingCharges"
            "InterestPaidCFF"
            "ProceedsFromStockOptionExercised"
            "CashDividendsPaid"
            "PreferredStockDividendPaid"
            "CommonStockDividendPaid"
            "NetPreferredStockIssuance"
            "PreferredStockPayments"
            "PreferredStockIssuance"
            "NetCommonStockIssuance"
            "CommonStockPayments"
            "CommonStockIssuance"
            "NetIssuancePaymentsOfDebt"
            "NetShortTermDebtIssuance"
            "ShortTermDebtPayments"
            "ShortTermDebtIssuance"
            "NetLongTermDebtIssuance"
            "LongTermDebtPayments"
            "LongTermDebtIssuance"
            "InvestingCashFlow"
            "CashFromDiscontinuedInvestingActivities"
            "CashFlowFromContinuingInvestingActivities"
            "NetOtherInvestingChanges"
            "InterestReceivedCFI"
            "DividendsReceivedCFI"
            "NetInvestmentPurchaseAndSale"
            "SaleOfInvestment"
            "PurchaseOfInvestment"
            "NetInvestmentPropertiesPurchaseAndSale"
            "SaleOfInvestmentProperties"
            "PurchaseOfInvestmentProperties"
            "NetBusinessPurchaseAndSale"
            "SaleOfBusiness"
            "PurchaseOfBusiness"
            "NetIntangiblesPurchaseAndSale"
            "SaleOfIntangibles"
            "PurchaseOfIntangibles"
            "NetPPEPurchaseAndSale"
            "SaleOfPPE"
            "PurchaseOfPPE"
            "CapitalExpenditureReported"
            "OperatingCashFlow"
            "CashFromDiscontinuedOperatingActivities"
            "CashFlowFromContinuingOperatingActivities"
            "TaxesRefundPaid"
            "InterestReceivedCFO"
            "InterestPaidCFO"
            "DividendReceivedCFO"
            "DividendPaidCFO"
            "ChangeInWorkingCapital"
            "ChangeInOtherWorkingCapital"
            "ChangeInOtherCurrentLiabilities"
            "ChangeInOtherCurrentAssets"
            "ChangeInPayablesAndAccruedExpense"
            "ChangeInAccruedExpense"
            "ChangeInInterestPayable"
            "ChangeInPayable"
            "ChangeInDividendPayable"
            "ChangeInAccountPayable"
            "ChangeInTaxPayable"
            "ChangeInIncomeTaxPayable"
            "ChangeInPrepaidAssets"
            "ChangeInInventory"
            "ChangeInReceivables"
            "ChangesInAccountReceivables"
            "OtherNonCashItems"
            "ExcessTaxBenefitFromStockBasedCompensation"
            "StockBasedCompensation"
            "UnrealizedGainLossOnInvestmentSecurities"
            "ProvisionandWriteOffofAssets"
            "AssetImpairmentCharge"
            "AmortizationOfSecurities"
            "DeferredTax"
            "DeferredIncomeTax"
            "DepreciationAmortizationDepletion"
            "Depletion"
            "DepreciationAndAmortization"
            "AmortizationCashFlow"
            "AmortizationOfIntangibles"
            "Depreciation"
            "OperatingGainsLosses"
            "PensionAndEmployeeBenefitExpense"
            "EarningsLossesFromEquityInvestments"
            "GainLossOnInvestmentSecurities"
            "NetForeignCurrencyExchangeGainLoss"
            "GainLossOnSaleOfPPE"
            "GainLossOnSaleOfBusiness"
            "NetIncomeFromContinuingOperations"
            "CashFlowsfromusedinOperatingActivitiesDirect"
            "TaxesRefundPaidDirect"
            "InterestReceivedDirect"
            "InterestPaidDirect"
            "DividendsReceivedDirect"
            "DividendsPaidDirect"
            "ClassesofCashPayments"
            "OtherCashPaymentsfromOperatingActivities"
            "PaymentsonBehalfofEmployees"
            "PaymentstoSuppliersforGoodsandServices"
            "ClassesofCashReceiptsfromOperatingActivities"
            "OtherCashReceiptsfromOperatingActivities"
            "ReceiptsfromGovernmentGrants"
            "ReceiptsfromCustomers"
        )
    }

    PROCESS
    {
        foreach ($q in $Report)
        {
            $body = switch($q)
            {
                "IncomeStatement" { $income; break }
                "BalanceSheet" { $balance; break }
                "CashFlowStatement" { $cash; break }
            }
    
            ### Session uses a persistent cookie for Yahoo Finance access, see CoreData.ps1 for info
            $data = (Invoke-RestMethod -Method GET -WebSession $Script:yahoo `
                -Uri ($uriPrefix + (($body | ForEach-Object { "$frequency$_" }) -join "%2C") + $uriSuffix)).timeseries.result
            
            $dates = $data[0].timestamp | ForEach-Object { [System.DateTimeOffset]::FromUnixTimeSeconds($_).Date.ToString("yyyy-MM-dd") }
    
            for ($a = 0; $a -lt $dates.Count; $a++)
            {
                $temp = switch ((Get-PSCallStack)[1].Command)
                {
                    "Add-StockFundamentalData" { [ordered]@{"StockID" = [int]$stockID; "ReportDate" = $dates[$a]} }
                    Default { [ordered]@{"StockSymbol" = $Symbol; "ReportDate" = $dates[$a]} }
                }

                foreach ($x in $body)
                {
                    ### The simplest way to handle zeroes, decimals, bigints, and nulls mixed in reports with Yahoo's system
                    ### The "0" in finally will catch decimals or floats (shudder) that are "0.0"
                    try
                    {
                        switch ($q)
                        {
                            "IncomeStatement"
                            {
                                if (@("BasicEPS","DilutedEPS","DividendPerShare","NormalizedBasicEPS","NormalizedDilutedEPS","TaxRateForCalcs") -notcontains $x)
                                { $temp.Add($x,[Int64]($data[$data.meta.type.IndexOf("quarterly$x")]."quarterly$x"[$a].reportedValue.raw)) }
                                else
                                { $temp.Add($x,[Decimal]($data[$data.meta.type.IndexOf("quarterly$x")]."quarterly$x"[$a].reportedValue.raw)) }
                                
                                break
                            }

                            Default
                            { $temp.Add($x,[Int64]($data[$data.meta.type.IndexOf("quarterly$x")]."quarterly$x"[$a].reportedValue.raw)) }
                        }
                    }
                    catch { $temp.Add($x,$null) }
                    finally
                    {
                        if ($temp.$x -eq 0)
                        { $temp.$x = $null }
                    }
                }
    
                [void]$output.Add([PSCustomObject]$temp)
            }
        }

        return $output
    }
}