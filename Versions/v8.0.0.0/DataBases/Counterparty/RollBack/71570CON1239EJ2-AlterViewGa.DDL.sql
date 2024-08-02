USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_GuaranteeRemained]    Script Date: 7/13/2024 1:36:51 PM ******/
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
--71410CON1199EJ1-InquiryReportpas-AlterviewGa.DDL
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------

CREATE VIEW [dbo].[Vw_GuaranteeRemained]
AS

with GuranteeRiskCoefficientConfig as 
(
select 
	[value],
	EffectiveDate,
	ExpirationDate
from ConfigHistory 
where [key]=N'cp:GuranteeRiskCoefficient'
)
SELECT        
t1.Id,
t1.MainCustomerId as MainCustomerId,
t1.MainCustomerNumber as  MainCustomerNumber,
t1.CentralBankRequestNumber,
t1.GuaranteeNumber,
t1.GuaranteeFileId, 
t1.IsWithoutCommitment,
t1.CostEQ,
t1.DepositRemainEq,
t1.DurationDays, 
t1.GRNTRequestDate, 
t1.CalculateDate,
t1.IsActive,
t1.IsPartialSeized,
t1.SeizedDate,
t1.CustomerResponsibilityRemainedEq,
t1.CashPaidAmountEQ,
t1.StatusTitle,
t1.EndDate,
t1.CurrencyId,
t1.IssueDate,
t1.SanctionNumber, 
t1.SanctionDate, 
t1.PersianSanctionDate, 
t1.PersianCalculateDate,
t1.ApprovalRefrence,
t1.GuaranteeTypeTitle,
t1.IsODSData,
t1.BranchId,
t1.StatusTitleId,
t1.LateInterestAccRemainEQ, 
t1.PenaltyAccRemainEQ, 
t1.NonCashFreeAmountEQ,
t1.ResourceCode, 
t1.OverUsanceACCRemained,
t1.DoubtfulACCRemained,
t1.FifthYearRemained,
t1.LoanRemained,
t1.PersianIssueDate,
t1.PersianEndDate,
t1.ContractNumber, 
t1.PenaltyAmount, 
t1.GRNTDoubtfulRemained, 
t1.PureCost,
t1.LateInterestRate,
isnull(t1.DepositRemainEq ,0) as PrePaymentOrCashPaidAmount, ---- پیش دریافت ضمانت نامه یا سسپرده نقدی ضمانت نامه
(
		case when t3.CustomerId is not null  and IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0))
		     when t3.CustomerId is not null  and IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is  not null then 0
		     when t3.CustomerId is not null  and IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then isnull(CustomerResponsibilityRemainedEq,0)
		else 0 
		end
) as NationalDevplomentFundAmountORG, ---- مانده خالص صندوق تونسعه ملی

case when IsWithoutCommitment=1  then 0 
     when  t1.IsPartialSeized=0 and SeizedDate is null  then Isnull(t1.CostEQ,0)
     when  t1.IsPartialSeized=0 and SeizedDate is not null  then 0
	 when  t1.IsPartialSeized=1   then isnull(CustomerResponsibilityRemainedEq,0)
	 end as ImpureCommitmentsRemained, ----- مانده ناخالص

 case 
     when t3.CustomerId is not null   then 0 
     when  IsWithoutCommitment=1    then 0 
	 when t3.CustomerId is  null and IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then  Isnull(t1.CostEQ,0)  
	 when t3.CustomerId is  null and IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is not  null then  0
	 when t3.CustomerId is  null and IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then  isnull(CustomerResponsibilityRemainedEq,0)
  end  as  TotalImpureCommitmentRemainedAppliedConsiderations, --- مانده ناخالص بعد از حذف صندوق توسعه ملی ها
 
 case
 when  IsWithoutCommitment=1 then 0 
 when   IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then   (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0)) 
 when IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is not  null then  0
 when IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then  isnull(CustomerResponsibilityRemainedEq,0)
 end as  PureCommitmentsRemained, ----- مانده خالص بدون حذف صندوق توسعه ملی و  بدون اعمال ضریب

 case
 when  IsWithoutCommitment=1 then 0 
 when   IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then   (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0)) 
 when IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is not  null then  0
 when IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then  isnull(CustomerResponsibilityRemainedEq,0)
 end
 * (
     select [Value] from GuranteeRiskCoefficientConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate() )
	) as PureCommitmentsRemainedWithConvertCoefficient,-- مانده خالص با ضریب  تبدیل بدون حذف صندوق توسعه ملی

 case 
 when t3.CustomerId is not null then 0
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0)) 
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is not null then 0
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then isnull(CustomerResponsibilityRemainedEq,0)
 else (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0))
 end as TotalPureCommitmentRemainedAppliedConsiderations, ---- مانده خالص با حذف صندوق توسعه ملی ها بدون اعمال ضریب تبدیل

  case 
 when t3.CustomerId is not null then 0
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is null then (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0)) 
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=0 and SeizedDate is not null then 0
 when t3.CustomerId is  null and  IsWithoutCommitment<>1 and t1.IsPartialSeized=1  then isnull(CustomerResponsibilityRemainedEq,0)
 else (Isnull(t1.CostEQ,0)-isnull(t1.DepositRemainEq,0))
 end

 * (
     select [Value] from GuranteeRiskCoefficientConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate() )
	) as TotalPureCommitmentRemainedAppliedConsiderationsWithConvertCoefficient, ---- مانده خالص با اعمال ضریب تبدیل و اعمال صندوق توسعه ملی ها

( select [Value]    from GuranteeRiskCoefficientConfig where t1.CalculateDate >=EffectiveDate and t1.CalculateDate < isnull(ExpirationDate,getdate()) ) as ConvertCoefficientListStr --- ضریب تبدیل لحاظ شده

fROM            
Common.dbo.GuaranteeRemained AS t1 
INNER JOIN dbo.Vw_Customer AS t2 ON t1.MainCustomerId = t2.Id
left join NationalDevelopmentFundCustomer t3 on t3.CustomerId = t1.MainCustomerId and (t1.CalculateDate>=CreatedDate and t1.CalculateDate < isnull(deleteddate,getdate())) 

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "t1"
            Begin Extent = 
               Top = 7
               Left = 48
               Bottom = 170
               Right = 382
            End
            DisplayFlags = 280
            TopColumn = 75
         End
         Begin Table = "t2"
            Begin Extent = 
               Top = 175
               Left = 48
               Bottom = 338
               Right = 329
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Vw_GuaranteeRemained'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'Vw_GuaranteeRemained'
GO


