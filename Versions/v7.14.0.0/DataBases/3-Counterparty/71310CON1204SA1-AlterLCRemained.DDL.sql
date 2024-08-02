USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_LCRemained]    Script Date: 5/12/2024 10:50:23 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[Vw_LCRemained]
AS
with LCCalculationCoeffiecientWhichHasNextDocumentConfig as 
(
select 
	[value],
	EffectiveDate,
	ExpirationDate
from ConfigHistory 
where [key]=N'cp:LCCalculationCoeffiecientWhichHasNextDocument'
),
NormalLCCalculationCoeffiecientConfig as 
(
select 
	[value],
	EffectiveDate,
	ExpirationDate
from ConfigHistory 
where [key]=N'cp:NormalLCCalculationCoeffiecient'
)
SELECT 
	t1.[Id],
    t2.MainCustomerId as  [MainCustomerId], 
	t2.MainCustomerNumber as [MainCustomerNumber],	
	CentralBankCreditCode, 
	CreditNumber, 
	CreditId, 
	CustomerAssuranceAccountEq, 
	AcceptanceDebtAccountEq, 
	PrepaymentEQ, 
	LCTypeCode, 
	Duration, 
	StartDate, 
	CalculateDate, 
    PersianCalculateDate, 
	CreditTypeName, 
	LCTotalWorthEQ, 
	CurrencyId, 
	BranchId,
	PersianStartDate, 
	SanctionDate, 
	PersianSanctionDate, 
	RefrencePerson, 
	SanctionNumber, 
	DebtorsAccountEQ, 
	HasPrePayment, 
	IsODSData, 
	PenaltyAccountEQ, 
    LCServiceWorthEQ, 
	LCProductWorthEQ, 
	RemianingAmountEQ, 
	LoanPaymentAmountEQ, 
	MainAccountEQ, 
	InterestAccountEQ,
	CreditLastStatus,
	[OverUsanceACCRemained],
	[DoubtfulACCRemained],
	[FifthYearRemained],
	[PersianExpiryDate],
	[SupplyResource],
	PersianRequestDate,
	CustomerAssuranceAccountEq ImpureCommitmentsRemained,

	(
		case when t3.CustomerId is not null 
		then (CustomerAssuranceAccountEq - PrepaymentEQ) 
		else 0 
		end
	) as NationalDevplomentFundAmountORG,

	(CustomerAssuranceAccountEq - PrepaymentEQ) - 
	(
		case when t3.CustomerId is not null 
		then (CustomerAssuranceAccountEq - PrepaymentEQ) 
		else 0 
		end
	) as PureCommitmentsRemained,

	((CustomerAssuranceAccountEq - PrepaymentEQ) - 
	(
		case when t3.CustomerId is not null 
		then (CustomerAssuranceAccountEq - PrepaymentEQ) 
		else 0 
		end
	)) * 
	(
		case when t1.DebtorsAccountEQ <> 0 
		then (select [Value] from LCCalculationCoeffiecientWhichHasNextDocumentConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate())) 
		else (select [Value] from NormalLCCalculationCoeffiecientConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate()))  
		end
	) as PureCommitmentsRemainedWithConvertCoefficient,
	(
		case when t1.DebtorsAccountEQ <> 0 
		then (select [Value] from LCCalculationCoeffiecientWhichHasNextDocumentConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate())) 
		else (select [Value] from NormalLCCalculationCoeffiecientConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate()))  
		end 
	)as ConvertCoefficientListStr
from [COMMON].[dbo].[LCRemained] t1
join Vw_SecondaryCustomerMapping t2 on t1.MainCustomerId=t2.SecondaryCustomerId
left join NationalDevelopmentFundCustomer t3 on t3.CustomerId = t1.MainCustomerId and (t1.CalculateDate>=CreatedDate and t1.CalculateDate < isnull(deleteddate,getdate())) 

GO


