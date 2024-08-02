USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_LCRemained]    Script Date: 5/12/2024 11:18:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


ALTER   VIEW [dbo].[Vw_LCRemained]
AS
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
 PersianRequestDate 

from [COMMON].[dbo].[LCRemained] t1
join Vw_SecondaryCustomerMapping t2 on t1.MainCustomerId=t2.SecondaryCustomerId
GO


