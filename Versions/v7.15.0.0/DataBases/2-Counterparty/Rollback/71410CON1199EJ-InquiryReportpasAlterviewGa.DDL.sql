USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_GuaranteeRemained]    Script Date: 6/5/2024 10:01:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Elmira Javadpour
--CreatedDate: 1401/12/08
--Subject : ضمانت نامه
--ChangeDescription 
--51510995MG-14020316
--LateInterestRate  افزودن فیلد نرخ سود معادل 
--713601207EJ-14030229-FilterCustomerWithInvalidShahabCodeInSepah   -- فیلتر کردن مشتریانی که کد شهاب ندارند یا طولشان کمتر از 16 رقم هست و کد شهاب دایم ندارند در سپه
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------

CREATE VIEW [dbo].[Vw_GuaranteeRemained]
AS
SELECT        t1.Id, t1.MainCustomerId as MainCustomerId, t1.MainCustomerNumber as  MainCustomerNumber, t1.CentralBankRequestNumber, t1.GuaranteeNumber, t1.GuaranteeFileId, t1.IsWithoutCommitment, t1.CostEQ, t1.DepositRemainEq, t1.DurationDays, t1.GRNTRequestDate, 
                         t1.CalculateDate, t1.IsActive, t1.IsPartialSeized, t1.SeizedDate, t1.CustomerResponsibilityRemainedEq, t1.CashPaidAmountEQ, t1.StatusTitle, t1.EndDate, t1.CurrencyId, t1.IssueDate, t1.SanctionNumber, t1.SanctionDate, 
                         t1.PersianSanctionDate, t1.PersianCalculateDate, t1.ApprovalRefrence, t1.GuaranteeTypeTitle, t1.IsODSData, t1.BranchId, t1.StatusTitleId, t1.LateInterestAccRemainEQ, t1.PenaltyAccRemainEQ, t1.NonCashFreeAmountEQ, 
                         t1.ResourceCode, t1.OverUsanceACCRemained, t1.DoubtfulACCRemained, t1.FifthYearRemained, t1.LoanRemained, t1.PersianIssueDate, t1.PersianEndDate, t1.ContractNumber, t1.PenaltyAmount, t1.GRNTDoubtfulRemained, 
                         t1.PureCost, t1.LateInterestRate
FROM            Common.dbo.GuaranteeRemained AS t1 INNER JOIN
                dbo.Vw_Customer AS t2 ON t1.MainCustomerId = t2.Id
GO


