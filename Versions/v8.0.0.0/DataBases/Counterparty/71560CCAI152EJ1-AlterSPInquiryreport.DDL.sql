USE [Counterparty]
GO
/****** Object:  StoredProcedure [dbo].[SP_FillInquiryReportData]    Script Date: 7/9/2024 2:03:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Elmira Javadpour
--CreatedDate: -
--Subject : --محاسبه ایتم های مختلق گزارش استعلام سپه 
--ChangeDescription 
--514011020EJ-14020427
-- LoanDelayedPenaltyAmountEq =  تغییر در محاسبه فرمول خسارت تاخیر برای پرونده های غیر او دی اسی وجه التزام شد جمع سه وجه التزام طبقات 
--74301100EJ-14020803-VajholeltezamPardakhtnashode---اصلاح فرمول خسارت تاخیر
---2-79401152EJ-14021201-FillCustomerListnvalidNationalcode add [SP_CPReports_FillFlatTables]  اضافه شدن این اس پی ته اس پی اصلی
--1-71170CCAI121EJ-14030201-InquiryReportGaurantor add CalculateDate Filter to vw_Guarantor
---1-71240CCAI125EJ-14030208-inquiryReportLoanIndexPersianCalc  تغییر فیلتر تاریخ از میلادی به شمسی به خاطر ایندکس تسهیلات روی این تاریخ شمسی
--71560CCAI152EJ1-AlterSPInquiryreport.DDL
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------


ALTER  PROCEDURE [dbo].[SP_FillInquiryReportData] (@CalculateDate Date)  
    
AS  
BEGIN  
    
  SET NOCOUNT ON;  
  
  
  ------------------------------------------------------------------------------------------------------  
  
  -------------------------------------------initialization Part  
  ------------------------------------------------------------------------------------------------------  
  
  Drop table if exists  #CustomerListForCalc  
  
  drop table if exists #GetAllMandeTashilatRiali  
  
  drop table if exists  #DelyaedPenaltyAmount  
  drop table if exists #InternalLCDoubtfullAmountEq  
  drop table if exists #GuaranteeCurrentAmountEq  
  drop table if exists #GuaranteeDebtorAmountEq  
  drop table if exists #GuaranteeDoubtfullAmountEq  
  
  drop table if exists #InDirectCommitmentsAmountEq  
  
  drop table if exists #TotalAssuranceAmountEq;  
  
  --truncate table InquiryReportData;  
  truncate table ETL_TMP_InquiryReportData   
  
    
  declare @PersianTransactionDate nvarchar(255),@PersianCalculateDate  nvarchar(255);  

  select @PersianTransactionDate=P_DATE_N from Calendar where g_date=@CalculateDate;  
  select @PersianCalculateDate=P_DATE from Calendar where g_date=@CalculateDate;  
  
     declare @LoanStatusTypeLoanPaymentStatusId bigint  
   select @LoanStatusTypeLoanPaymentStatusId=cast(value as bigint) from Vw_Config where [key]=N'com:LoanStatusTypeLoanPaymentStatusId';  
  
  
  
  
  -- if not exists (select * from sys.columns where object_name(object_id)='InquiryReportData' and name=N'CalculateDate')  
  --begin  
  --alter table InquiryReportData add CalculateDate date,PersianCalculateDate nvarchar(255)  
  --end;  
  
  
------------------ استخراج لیست مشتریانی که باید برایشون محاسبه گزارش استعلام انجام داد  
  
  /*with CustomerListForCalc as (  
  select distinct t1.CustomerId,t2.CustomerName,t2.CustomerNumber from CounterPartyGroupCustomer t1   
  join  
  VW_customer t2 on t1.CustomerId=t2.id  
    
    
   where cast(CalculateDate as date)=@CalculateDate)*/  
  
  
     
with CustomerListForCalc as (  
SELECT distinct a.*,t2.CustomerName  from  
   (select distinct MainCustomerNumber as CustomerNumber ,MainCustomerId AS CustomerId from Vw_LoanRemained    
   where cast(CalculateDate as date)=@CalculateDate and LoanStatusId=@LoanStatusTypeLoanPaymentStatusId  
  
  union all  
  
  
    select MainCustomerNumber,MainCustomerId from Vw_GuaranteeRemained  where cast(CalculateDate as date)=@CalculateDate  
 union all  
 select MainCustomerNumber,MainCustomerId from Vw_LCRemained  where  cast(CalculateDate as date)=@CalculateDate  
   
 )a JOIN Vw_Customer T2 ON A.CustomerId=t2.Id)  
    
  
  
   select * into #CustomerListForCalc from CustomerListForCalc;  
  
     Create Nonclustered index nci_CustomerListForCalc_CustomerId on #CustomerListForCalc (CustomerId) ;  
    
     Create Nonclustered index nci_CustomerListForCalc_CustomerNumber on #CustomerListForCalc (CustomerNumber) ;  
  
   --------------------------------------------------------------------------------------------------  
  
   ----------------------------------استخراج مبلغ تسهیلات به تفکیک طبقه و مشتری--------------------  
  
   ---------------------------------------------------------------------------------------------------  
  
  
   --select @LoanStatusTypeLoanPaymentStatusId  
  
   with GetAllMandeTashilatRiali as (  
  
   SELECT MainCustomerNumber,MainCustomerId,  
 (SUM(MainRemained) - SUM(AfterDeliveryAccRemained)) MandeJari,  
 SUM(AfterDeliveryAccRemained) MandeBadAzsarresid,  
 SUM(OverUsanceAccRemained) MandeSarresidGozashte,  
 SUM(PostPonedAccRemained) MandeMoaavagh,  
 SUM(DoubtfulAccRemained) MandeMashkookVosooll   
FROM  #CustomerListForCalc t1 join Vw_LoanRemained t2 on t1.CustomerId=t2.MainCustomerId  
WHERE CalculateDate=@CalculateDate   
and LoanStatusId=@LoanStatusTypeLoanPaymentStatusId  
GROUP BY MainCustomerNumber,MainCustomerId  
  
)  
  
  
  
  
select * into #GetAllMandeTashilatRiali from GetAllMandeTashilatRiali;  
  
Create Nonclustered index nci_GetAllMandeTashilatRiali_MainCustomerId on #GetAllMandeTashilatRiali (MainCustomerId) ;  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select MainCustomerNumber as CustomerNumber,  
MainCustomerId as CustomerId ,  
MandeJari as LoanCurrentAmountEq ,  
MandeSarresidGozashte as LoanOverUsancedAmountEq ,  
MandeMoaavagh LoanPostponedAmountEq,  
MandeMashkookVosooll LoanDoubtfullAmountEq,  
t2.CustomerName as CustomerName  
  
 from #GetAllMandeTashilatRiali t1 join #CustomerListForCalc t2 on t1.MainCustomerId=t2.CustomerId  
)src  
on (dest.[CustomerNumber]=src.[CustomerNumber])  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 [LoanCurrentAmountEq],  
 [LoanOverUsancedAmountEq],  
 [LoanPostponedAmountEq],  
 [LoanDoubtfullAmountEq]  
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.[LoanCurrentAmountEq],  
 src.[LoanOverUsancedAmountEq],  
 src.[LoanPostponedAmountEq],  
 src.[LoanDoubtfullAmountEq]  
   
   
 );  
  
-----------------------------------------------------------------------------------------------------------  
  
---------------------------------خسارت تاخیر پرونده های تسهیلات ریالی-------------------------------------  
  
  
----------------------------------------------------------------------------------------------------------  
  ---LoanCurrentPenaltyRemained = VajHolEltezamJari    
  
 with DelyaedPenaltyAmount as (  
  

 SELECT  a.MainCustomerNumber,a.MainCustomerId,SUM(a.LoanDelayedPenaltyAmountEq) LoanDelayedPenaltyAmountEq FROM 
  
(SELECT MainCustomerNumber,MainCustomerId,  
   
sum(isnull(DemandCommitmentPenalty,0)) LoanDelayedPenaltyAmountEq  
FROM  #CustomerListForCalc t1 join Vw_LoanRemained t2 on t1.CustomerId=t2.MainCustomerId  
WHERE CalculateDate=@CalculateDate  and isnull(isODSdata,0)=1  
GROUP BY MainCustomerNumber,MainCustomerId  
  
union all  
  
  
 
    SELECT MainCustomerNumber,MainCustomerId,  
 
--SUM(isnull(t2.LoanCurrentPenaltyRemained,0) + isnull(t2.VajHolEltezamSarResidGozahste,0)+isnull(t2.VajHolEltezamMashkookolvosool,0)+isnull(t2.VajHolEltezamMoavagh,0)) LoanDelayedPenaltyAmountEq  
SUM(t2.CommitmentPenaltyUnPaid) AS LoanDelayedPenaltyAmountEq -----  خسارت تاخیر برابر با وجه التزام پرداخت نشده  
FROM  #CustomerListForCalc t1 join Vw_LoanRemained t2 on t1.CustomerId=t2.MainCustomerId  
WHERE CalculateDate=@CalculateDate  and isnull(isODSdata,0)=0  
GROUP BY MainCustomerNumber,MainCustomerId  ) a

GROUP BY a.MainCustomerNumber,a.MainCustomerId
  
   
 )  
  
 select * into #DelyaedPenaltyAmount from DelyaedPenaltyAmount;  
   
 Create Nonclustered index nci_DelyaedPenaltyAmount_MainCustomerId on #DelyaedPenaltyAmount (MainCustomerId) ;  
  
  
 update t2 set LoanDelayedPenaltyAmountEq=t1.LoanDelayedPenaltyAmountEq  
  
 from #DelyaedPenaltyAmount t1 join ETL_TMP_InquiryReportData t2 on t1.MainCustomerId=t2.CustomerId;  
  
 -------------------------------------------------------------------------------------------------  
  
  
 ----------------جمع مبلغ تسهیلات دریافتی از محل صندوق توسعه ملی به تفکیک مشتری----------------  
  
 --------------------------------------------------------------------------------------------------  
  
   
 with LoanSandoghToseeMeliAmountEq as (  
  
  
  SELECT MainCustomerNumber,MainCustomerId,  
   
sum(isnull(GrantAmountEq,0))   LoanSandoghToseeMeliAmountEq  
FROM  #CustomerListForCalc t1 join Vw_LoanRemained t2 on t1.CustomerId=t2.MainCustomerId  
WHERE CalculateDate=@CalculateDate  and  
t2.contracttypeName  in (N'صندوق توسعه ملی',N'قرارداد صندوق توسعه ملی')  
  
GROUP BY MainCustomerNumber,MainCustomerId  
  
  
   
 )  
  
 update t2 set LoanSandoghToseeMeliAmountEq=t1.LoanSandoghToseeMeliAmountEq  
  
 from LoanSandoghToseeMeliAmountEq t1 join ETL_TMP_InquiryReportData t2 on t1.MainCustomerId=t2.CustomerId;  
  
   
  
 -----------------------------------------------------------------------------------------------------------  
  
---------------------------------جمع مبلغ اعتبار اسنادی جاری به تفکیک مشتری-------------------------------------  
  
  
----------------------------------------------------------------------------------------------------------  
  
  
 With InternlLCCurrentAmountEq as (  
  
 select MainCustomerNumber,  
 sum(CustomerAssuranceAccountEq) MandeKhales,  
 sum(isnull(LCTotalWorthEQ,0)) InternalLCCurrentAmountEq   ,
 sum(PrepaymentEQ) as PrepaymentAmountCurrentLc
from #CustomerListForCalc t1 join Vw_LCRemained A on t1.CustomerId=a.MainCustomerId  
where CreditLastStatus not in (N'تسويه شده',N'باطل شده',N'تشکيل شده',N'تکميل شده')  
  
 and CreditTypeName not like '%بدون تعهد%'   
 and CreditTypeName not like '%حواله%'   
 and (CreditTypeName like N'%داخلی%' or Credittypename like N'%داخلي%')  
 and isnull(HasPrePayment,1)=1   
 and CalculateDate = @CalculateDate  
 AND NOT EXISTS (select 1 from Vw_LoanRemaindLoanDebtConversion where subsystem=N'اعتبارات اسنادی' AND A.CreditId = SourceFileId)  
  
group by MainCustomerNumber  
)  
  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
InternalLCCurrentAmountEq ,  
t2.CustomerName   ,
t1.PrepaymentAmountCurrentLc

  
 from InternlLCCurrentAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 InternalLCCurrentAmountEq  ,
 PrepaymentAmountCurrentLc
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.InternalLCCurrentAmountEq,
 src.PrepaymentAmountCurrentLc
  
   
 )  
  
 when matched then  
 update   
 set dest.InternalLCCurrentAmountEq=src.InternalLCCurrentAmountEq
   , dest.PrepaymentAmountCurrentLc=src.PrepaymentAmountCurrentLc;  
  
 ------------------------------------------------------------------------------------------------------------------  
  
 ------------------جمع مبلغ اعتبار اسنادی تبدیل به بدهی شده (بدهکاران) به تفکیک مشتری-----------------------------  
  
 -----------------------------------------------------------------------------------------------------------------------  
  With InternalLCDebtorAmountEq as (  
  
 select MainCustomerNumber,MainCustomerId,  
 sum(DebtorsAccountEQ) MandeKhales,  
 sum(isnull(LCTotalWorthEQ,0)) InternalLCDebtorAmountEq   ,
 sum(PrepaymentEQ) as PrepaymentAmountDebtorLc
from #CustomerListForCalc t1 join Vw_LCRemained A on t1.CustomerId=a.MainCustomerId  
where  
  
    CreditLastStatus not in (N'تسويه شده',N'باطل شده',N'تشکيل شده',N'تکميل شده')  
 and CreditTypeName not like '%بدون تعهد%'   
 and CreditTypeName not like '%حواله%'   
 and (CreditTypeName like N'%داخلی%' or Credittypename like N'%داخلي%')  
 and isnull(HasPrePayment,1)=1   
 and CalculateDate = @CalculateDate  
 and exists (select 1 from Vw_LoanRemaindLoanDebtConversion where subsystem=N'اعتبارات اسنادی' and SourceFileId = a.CreditId)  
group by MainCustomerNumber,MainCustomerId  
)  
   
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
InternalLCDebtorAmountEq ,  
t2.CustomerName   ,
t1.PrepaymentAmountDebtorLc
  
 from InternalLCDebtorAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 InternalLCDebtorAmountEq  ,
 PrepaymentAmountDebtorLc
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.InternalLCDebtorAmountEq,
 src.PrepaymentAmountDebtorLc
   
 )  
  
 when matched then  
 update   
 set dest.InternalLCDebtorAmountEq=src.InternalLCDebtorAmountEq 
  , dest.PrepaymentAmountDebtorLc=src.PrepaymentAmountDebtorLc;  
  
  
  
   
 -------------------------------------------------------------------------------------------------------------------  
  
 -------------------------------------جمع مبلغ اعتبار اسنادی مشکوک الوصول به تفکیک مشتری------------------------  
  
 --------------------------------------------------------------------------------------------------------------------  
  
  With InternalLCDoubtfullAmountEq as (  
  
  select  c.MainCustomerNumber,c.MainCustomerId,sum(c.Doubtfull) DoubtfullAmountEq,sum(c.InternalLCDoubtfullAmountEq) InternalLCDoubtfullAmountEq,
  sum(c.PrepaymentAmountMashkookLc) as PrepaymentAmountMashkookLc
  
  from   
 (select distinct a.MainCustomerNumber,a.MainCustomerId,  
 sum(LOAN.DoubtfulAccRemained) Doubtfull,  
 sum(isnull(LCTotalWorthEQ,0)) InternalLCDoubtfullAmountEq ,
 sum(PrepaymentEQ) as PrepaymentAmountMashkookLc
from #CustomerListForCalc t1 join Vw_LCRemained A on t1.CustomerId=a.MainCustomerId  
 INNER JOIN Vw_LoanRemaindLoanDebtConversion LC_LOAN ON LC_LOAN.SourceFileId= a.CreditId  
 INNER JOIN Vw_LoanRemained LOAN ON LOAN.pid = LC_LOAN.LoanFileId  
where  
CreditLastStatus not in (N'تسويه شده',N'باطل شده',N'تشکيل شده',N'تکميل شده')  
 and CreditTypeName not like '%بدون تعهد%'   
 and CreditTypeName not like '%حواله%'   
 and (CreditTypeName like N'%داخلی%' or Credittypename like N'%داخلي%')  
 and isnull(HasPrePayment,1)=1   
 and a.CalculateDate = @CalculateDate  
 and loan.CalculateDate=@CalculateDate  
 and LC_LOAN.SUBSYSTEM=N'اعتبارات اسنادی'  
 and loan.LoanStatus like N'%مش%'  
   and isnull(a.isodsdata,0)=0  
group by a.MainCustomerNumber,a.MainCustomerId  
  
  
union all  
  
select MainCustomerNumber,MainCustomerId,  
 sum(PenaltyAccountEQ) Doubtfull,  
 sum(isnull(LCTotalWorthEQ,0)) InternalLCDoubtfullAmountEq ,
 sum(PrepaymentEQ) as PrepaymentAmountMashkookLc
from #CustomerListForCalc t1 join Vw_LCRemained A on t1.CustomerId=a.MainCustomerId  
where   
CreditLastStatus not in (N'تسويه شده',N'باطل شده',N'تشکيل شده',N'تکميل شده') -------------  را باید پرسید اضافه کرد یا خیر ؟ تکمیل شده تشکیل شده  
 and CreditTypeName not like '%بدون تعهد%'   
 and CreditTypeName not like '%حواله%'   
 and (CreditTypeName like N'%داخلی%' or Credittypename like N'%داخلي%')  
 and isnull(HasPrePayment,1)=1   
 and CalculateDate = @CalculateDate  
 and PenaltyAccountEQ <> 0  ------------------ اینو خودم اضافه کردم تا انبارداده جواب دهد نمیشه هر چی او دی اس هست را مشکوک فرض کنیم که  
 and isnull(isodsdata,0)=1  
  
  
group by MainCustomerNumber,MainCustomerId)c  
group by c.MainCustomerNumber,c.MainCustomerId  
  
)  
  
  
  
 select * into #InternalLCDoubtfullAmountEq from InternalLCDoubtfullAmountEq  
  
    
 Create Nonclustered index nci_InternalLCDoubtfullAmountEq_MainCustomerNumber on #InternalLCDoubtfullAmountEq (MainCustomerNumber) ;  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
InternalLCDoubtfullAmountEq ,  
DoubtfullAmountEq,  
t2.CustomerName  ,
t1.PrepaymentAmountMashkookLc
  
 from #InternalLCDoubtfullAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 InternalLCDoubtfullAmountEq  ,
 PrepaymentAmountMashkookLc
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.DoubtfullAmountEq ,
 src.PrepaymentAmountMashkookLc
   
 )  
  
 when matched then  
 update   
 set dest.InternalLCDoubtfullAmountEq=src.DoubtfullAmountEq,
 dest.PrepaymentAmountMashkookLc=src.PrepaymentAmountMashkookLc;

 
  
 update t2 set InternalLCDoubtfullAmountEq=t1.InternalLCDoubtfullAmountEq  
  
 from #InternalLCDoubtfullAmountEq t1 join ETL_TMP_InquiryReportData t2 on t1.MainCustomerId=t2.CustomerId;  
  
  
 --------------------------------------------------------------------------------------------------------------  
  
 -------------------------------جمع مبلغ ضمانت نامه های جاری به تفکیک مشتری-----------------------  
  
 -----------------------------------------------------------------------------------------------------------------  
  
 With GuaranteeCurrentAmountEq as (  
  
 select c.MainCustomerId,c.MainCustomerNumber,sum(c.GuaranteeCurrentAmountEq) GuaranteeCurrentAmountEq  ,sum(c.PrepaymentAmountCurrentGa) PrepaymentAmountCurrentGa

  from  
  
  (SELECT MainCustomerId,
		  MainCustomerNumber,  
		  SUM(CostEQ) AS GuaranteeCurrentAmountEq ,
		  sum(DepositRemainEq) as PrepaymentAmountCurrentGa
	FROM  #CustomerListForCalc t1 join Vw_GuaranteeRemained a on t1.CustomerId=a.MainCustomerId  
	WHERE CalculateDate =@CalculateDate  
	and StatusTitle not in (N'آزاد شده به طور خودکار',N'آزاد شده',N'باطل شده به طور خودکار',N'باطل شده',N'حذف شده',N'بدهکاران') 
	AND NOT EXISTS (select 1 from Vw_LoanRemaindLoanDebtConversion where subsystem=N'ضمانت نامه' AND A.GuaranteeFileId = SourceFileId)  
	GROUP BY MainCustomerId,MainCustomerNumber  
 
)c  
  
group by c.MainCustomerNumber,c.MainCustomerId  
  
)  
  
  
select * into #GuaranteeCurrentAmountEq from GuaranteeCurrentAmountEq  
  
  Create Nonclustered index nci_GuaranteeCurrentAmountEq_MainCustomerNumber on #GuaranteeCurrentAmountEq (MainCustomerNumber) ;  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
GuaranteeCurrentAmountEq ,  
t2.CustomerName  ,
t1.PrepaymentAmountCurrentGa
  
 from #GuaranteeCurrentAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 GuaranteeCurrentAmountEq ,
 PrepaymentAmountCurrentGa
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.GuaranteeCurrentAmountEq,
 src.PrepaymentAmountCurrentGa
  
   
 )  
  
 when matched then  
 update   
 set dest.GuaranteeCurrentAmountEq=src.GuaranteeCurrentAmountEq,
 dest.PrepaymentAmountCurrentGa=src.PrepaymentAmountCurrentGa;
 
  
  
  
   
 -------------------------------------------------------------------------------------------------------------------------  
  
 -------------------------------جمع مبلغ ضمانت نامه های تبدیل بدهی شده به تفکیک مشتری---------------------------------------------------------  
  
 ---- شامل ضمانت نامه های همه وضعیت ها می شود من جمله جاری ها البته چون در اوردن ضمانت نامه های جاری تاکید کردم تبدیل بدهی شده ها جزش نباشد فکر کنم این دو با هم اشتراکی نداشته باشند  
  
 -------------------------------------------------------------------------------------------------------------------------------  
  
 With GuaranteeDebtorAmountEq as (  
  
 select c.MainCustomerId,c.MainCustomerNumber,sum(c.GuaranteeDebtorAmountEq) GuaranteeDebtorAmountEq,sum(c.PrepaymentAmountDebtorGa)  PrepaymentAmountDebtorGa
 --,sum(c.remained) remained   
 from  
  
  (SELECT MainCustomerId,MainCustomerNumber,  
  SUM(CostEQ) AS GuaranteeDebtorAmountEq ,
    sum(DepositRemainEq) as PrepaymentAmountDebtorGa
   --,sum(CostEQ-DepositRemainEq) AS remained  
FROM   #CustomerListForCalc t1 join Vw_GuaranteeRemained a on t1.CustomerId=a.MainCustomerId  
WHERE CalculateDate = @CalculateDate  
AND StatusTitle not in (N'آزاد شده به طور خودکار',N'آزاد شده',N'باطل شده به طور خودکار',N'باطل شده',N'حذف شده')
AND  EXISTS (select 1 from Vw_LoanRemaindLoanDebtConversion where subsystem=N'ضمانت نامه' AND A.GuaranteeFileId = SourceFileId)  
and isnull(isodsdata,0)=0  
GROUP BY MainCustomerId,MainCustomerNumber  
  
  
union all  
  
  
SELECT MainCustomerId,MainCustomerNumber,  
  SUM(CostEQ) AS GuaranteeDebtorAmountEq  ,
    sum(DepositRemainEq) as PrepaymentAmountDebtorGa
   --,sum(CostEQ-DepositRemainEq) AS remained  
FROM  #CustomerListForCalc t1 join Vw_GuaranteeRemained a on t1.CustomerId=a.MainCustomerId  
WHERE CalculateDate = @CalculateDate  
and StatusTitle =N'بدهکاران'   
and isnull(isodsdata,0)=1  
  
GROUP BY MainCustomerId,MainCustomerNumber  
  
)c  
  
group by c.MainCustomerNumber,c.MainCustomerId  
  
)  
  
  
select * into #GuaranteeDebtorAmountEq from GuaranteeDebtorAmountEq  
  Create Nonclustered index nci_GuaranteeDebtorAmountEq_MainCustomerNumber on #GuaranteeDebtorAmountEq (MainCustomerNumber) ;  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
GuaranteeDebtorAmountEq ,  
t2.CustomerName ,
t1.PrepaymentAmountDebtorGa
 from #GuaranteeDebtorAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 GuaranteeCurrentAmountEq  ,
 PrepaymentAmountDebtorGa
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.GuaranteeDebtorAmountEq ,
 src.PrepaymentAmountDebtorGa
  
   
 )  
  
 when matched then  
 update   
 set dest.GuaranteeDebtorAmountEq=src.GuaranteeDebtorAmountEq,
     dest.PrepaymentAmountDebtorGa=src.PrepaymentAmountDebtorGa;
 
  
  
  
  
  
  
  
 -------------------------------------------------------------------------------------------------------------------  
  
 --------------------------------جمع مبلغ ضمانت نامه های مشکوک الوصول به تفکیک مشتری  
  
 --------------------------------------------------------------------------------------------------------------------  
  
 With GuaranteeDoubtfullAmountEq as (  
  
 select c.MainCustomerId,c.MainCustomerNumber,sum(c.GuaranteeDoubtfullAmountEq) GuaranteeDoubtfullAmountEq  ,sum(c.PrepaymentAmountMashkookGa) PrepaymentAmountMashkookGa
  
  from  
  
  (SELECT MainCustomerId,MainCustomerNumber,  
  SUM(CostEQ) AS GuaranteeDoubtfullAmountEq  ,
      sum(DepositRemainEq) as PrepaymentAmountMashkookGa
   
FROM  #CustomerListForCalc t1 join Vw_GuaranteeRemained a on t1.CustomerId=a.MainCustomerId  
WHERE CalculateDate =@CalculateDate  
  
and StatusTitle like N'%مشکوک%'
--AND NOT EXISTS (select 1 from Vw_LoanRemaindLoanDebtConversion where subsystem=N'ضمانت نامه' AND A.GuaranteeFileId = SourceFileId)  
and isnull(isodsdata,0)=0  
  
GROUP BY MainCustomerId,MainCustomerNumber  
  
  
union all  
  
----- ods Mashkook ro motmaen nistam DWH query nadade bood agar mesl lc harchi toye ods hast beshe mashkook vosoll inam mishe mesl on kard  
  
SELECT MainCustomerId,MainCustomerNumber,  
  SUM(CostEQ) AS GuaranteeDoubtfullAmountEq  ,
    sum(DepositRemainEq) as PrepaymentAmountMashkookGa
  
FROM  #CustomerListForCalc t1 join Vw_GuaranteeRemained a on t1.CustomerId=a.MainCustomerId  
WHERE CalculateDate = @CalculateDate  
and StatusTitle like N'%مشکوک%'
and isnull(isodsdata,0)=1  
GROUP BY MainCustomerId,MainCustomerNumber  
  
  
)c  
  
group by c.MainCustomerNumber,c.MainCustomerId  
  
)  
  
  
select * into #GuaranteeDoubtfullAmountEq from GuaranteeDoubtfullAmountEq  
Create Nonclustered index nci_GuaranteeDoubtfullAmountEq_MainCustomerNumber on #GuaranteeDoubtfullAmountEq (MainCustomerNumber) ;  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t1.MainCustomerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
GuaranteeDoubtfullAmountEq ,  
t2.CustomerName   ,
t1.PrepaymentAmountMashkookGa
  
 from #GuaranteeDoubtfullAmountEq t1 join #CustomerListForCalc t2 on t1.MainCustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 GuaranteeDoubtfullAmountEq  ,
 PrepaymentAmountMashkookGa
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.GuaranteeDoubtfullAmountEq  ,
 src.PrepaymentAmountMashkookGa
  
   
 )  
  
 when matched then  
 update   
 set dest.GuaranteeDoubtfullAmountEq=src.GuaranteeDoubtfullAmountEq,
 dest.PrepaymentAmountMashkookGa=src.PrepaymentAmountMashkookGa;

 
  
  
  
-----------------------------------------------------------------------------------------------------------------  
  
  
 ---------------------------------------تعهدات غیر مستقیم-------------------------------------------------------  
  
 ------------------------------------------------------------------------------------------------------------------  
  
 with InDirectCommitmentsAmountEq as (  
   SELECT a.CustomerIdGuarantor AS CustomerId, SUM (isnull(amount,0)) AS InDirectCommitmentsAmountEq  
    FROM (SELECT VG.CustomerIdGuarantor,  
                 L.ApprovedAmount * VG.GuarantorPercent / 100 AS AMOUNT  
            FROM #CustomerListForCalc t1 join Vw_Guarantor VG on t1.CustomerId=vg.CustomerIdGuarantor  
                 INNER JOIN Vw_LoanRemained L  
                    ON L.PID = VG.PID AND L.CalculateDate = VG.CalculateDate
           WHERE  ( L.PersianCalculateDate = @PersianCalculateDate   AND VG.CalculateDate=@CalculateDate) And VG.SystemName = 'LOAN'    And VG.CustomerIdGuarantor IS NOT NULL   
          UNION ALL  
          SELECT VG.CustomerIdGuarantor, G.CostEQ * VG.GuarantorPercent / 100 AS AMOUNT  
            FROM #CustomerListForCalc t1 join Vw_Guarantor VG on t1.CustomerId=vg.CustomerIdGuarantor  
                 INNER JOIN Vw_GuaranteeRemained G  
                    ON     G.GuaranteeFileId = VG.PID 
                             AND G.CalculateDate = VG.CalculateDate  
           WHERE  ( G.CalculateDate = @CalculateDate   AND VG.CalculateDate=@CalculateDate) and VG.SystemName = 'GUARANTEE'  and VG.CustomerIdGuarantor IS NOT NULL    
          UNION ALL  
          SELECT VG.CustomerIdGuarantor,  
                 C.LCTotalWorthEQ * VG.GuarantorPercent / 100 AS AMOUNT  
            FROM #CustomerListForCalc t1 join Vw_Guarantor VG on t1.CustomerId=vg.CustomerIdGuarantor  
                 INNER JOIN Vw_LCRemained C  
                    ON C.CreditId = VG.PID AND C.CalculateDate=VG.CalculateDate
           WHERE (VG.CalculateDate=@CalculateDate AND C.CalculateDate=@CalculateDate) And VG.SystemName = 'CREDIT'  AND   VG.CustomerIdGuarantor IS NOT NULL)a  
GROUP BY a.CustomerIdGuarantor)  
  
select * into #InDirectCommitmentsAmountEq from InDirectCommitmentsAmountEq  
  
  
Create Nonclustered index nci_InDirectCommitmentsAmountEq_CustomerId on #InDirectCommitmentsAmountEq (CustomerId) ;  
  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t2.customerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
InDirectCommitmentsAmountEq ,  
t2.CustomerName   
  
 from #InDirectCommitmentsAmountEq t1 join #CustomerListForCalc t2 on t1.CustomerId=t2.CustomerId  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 InDirectCommitmentsAmountEq  
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.InDirectCommitmentsAmountEq  
  
   
 )  
  
 when matched then  
 update   
 set dest.InDirectCommitmentsAmountEq=src.InDirectCommitmentsAmountEq;  
  
  
 ------------------------------------------------------------------------------------------------------------------------  
  
 ----------------------------جمع مبلغ وثایق هر مشتری--------------------------------------------------------------------  
  
 ------------------------------------------------------------------------------------------------------------------------  
  
   
 with TotalAssuranceAmountEq as (  
  
   
  SELECT cast(OwnerCustomerNumber as numeric) AS CustomerNumber,  
    SUM(FileUsedCost)  AS TotalAssuranceAmountEq  
  FROM #CustomerListForCalc t1 join  VW_AssuranceInfoHistorical t2 on t1.CustomerNumber=t2.OwnerCustomerNumber  
  WHERE PersianTransactionDate = @PersianTransactionDate  
    GROUP BY OwnerCustomerNumber  
/*  
  
   SELECT a.CustomerNumber,  
  a.FileUsedCost AS TotalFileUsedCodeAssurance  
FROM  
  (SELECT cast(t2.MainCustomerNumber as numeric) AS CustomerNumber,  
    SUM(t1.FileUsedCost)             AS FileUsedCost  
  FROM Vw_LoanDebtConversionAssuranceInfoHistorical t1  
  JOIN Vw_LoanRemained t2  
  ON t1.FileId          =t2.pid  
  AND t2.CalculateDate=@CalculateDate  
  WHERE t1.PersianTransactionDate =@PersianTransactionDate  
  and t2.LoanStatus='پرداخت تسهيلات'  
  GROUP BY t2.MainCustomerNumber  
  UNION ALL  
  SELECT cast(OwnerCustomerNumber as numeric) AS CustomerNumber,  
    SUM(FileUsedCost)  AS TotalAssuranceAmountEq  
  FROM #CustomerListForCalc t1 join  VW_AssuranceInfoHistorical t2 on t1.CustomerNumber=t2.OwnerCustomerNumber  
  WHERE PersianTransactionDate = @PersianTransactionDate  
    GROUP BY OwnerCustomerNumber  
  )a;*/  
  
  
  )  
  
select * into #TotalAssuranceAmountEq from TotalAssuranceAmountEq  
Create Nonclustered index nci_TotalAssuranceAmountEq_CustomerNumber on #TotalAssuranceAmountEq (CustomerNumber) ;  
  
merge into [ETL_TMP_InquiryReportData] dest   
using   
(  
select  t2.customerNumber as CustomerNumber,  
t2.CustomerId as  CustomerId,  
TotalAssuranceAmountEq ,  
t2.CustomerName   
  
 from #TotalAssuranceAmountEq t1 join #CustomerListForCalc t2 on t1.CustomerNumber=t2.CustomerNumber  
)src  
on (dest.CustomerNumber=src.CustomerNumber)  
when not matched then  
insert   
 (  
 [CustomerNumber],  
 [CustomerName],  
 [CustomerId],  
 TotalAssuranceAmountEq  
   
 )  
  
 values   
 ( src.[CustomerNumber],  
 src.[CustomerName],  
 src.[CustomerId],  
 src.TotalAssuranceAmountEq  
  
   
 )  
  
 when matched then  
 update   
 set dest.TotalAssuranceAmountEq=src.TotalAssuranceAmountEq;  



 -----------------------------------------------------قیمت تمام شده سهام--------- StockPrice
 --with StockCostAmount as (select isnull(InvestmentAmount,0) as InvestmentAmount,CustomerId,UploadDate from BankInvestment t8 )
 with StockCostAmount  as (

select isnull(StockPrimeCost,0) as InvestmentAmount,CustomerId from CreditInstitueSubsets 
where @CalculateDate>=EffectiveDate and @CalculateDate<isnull(cast(expirationDate as date),getdate())

)
   update t1 set StockPrice=t2.InvestmentAmount from
   
  [ETL_TMP_InquiryReportData] t1 join StockCostAmount t2 on t1.CustomerId=t2.CustomerId
   --where t2.UploadDate=(select cast(max(UploadDate) as date) from BankInvestment where UploadDate <= @CalculateDate)



  ------------------------------------update calculateDate,PersianCalculateDat
  
  update ETL_TMP_InquiryReportData set calculateDate=@CalculateDate,PersianCalculateDate=@PersianTransactionDate;  
  
 --select * from InquiryReportData;  
truncate table InquiryReportData

insert into InquiryReportData 
(
	[CustomerNumber], 
	[CustomerName], 
	[CustomerId], 
	[LoanCurrentAmountEq], 
	[LoanOverUsancedAmountEq], 
	[LoanPostponedAmountEq], 
	[LoanDoubtfullAmountEq], 
	[LoanDelayedPenaltyAmountEq], 
	[InternalLCDoubtfullAmountEq], 
	[InternalLCDebtorAmountEq], 
	[InternalLCDelayedPenaltyAmountEq], 
	[InternalLCCurrentAmountEq], 
	[GuaranteeDoubtfullAmountEq], 
	[GuaranteeDebtorAmountEq], 
	[GuaranteeDelayedPenaltyAmountEq], 
	[GuaranteeCurrentAmountEq], 
	[InDirectCommitmentsAmountEq], 
	[LoanSandoghToseeMeliAmountEq], 
	[TotalAssuranceAmountEq], 
	[CalculateDate], 
	[PersianCalculateDate],
	PrepaymentAmountCurrentLc,
	PrepaymentAmountDebtorLc,
	PrepaymentAmountMashkookLc,
	PrepaymentAmountCurrentGa,
	PrepaymentAmountDebtorGa,
	PrepaymentAmountMashkookGa,

	StockPrice
	
	)

select 
	[CustomerNumber], 
	[CustomerName], 
	[CustomerId], 
	isnull([LoanCurrentAmountEq],				0) as [LoanCurrentAmountEq] ,
	isnull([LoanOverUsancedAmountEq],			0) as [LoanOverUsancedAmountEq] ,
	isnull([LoanPostponedAmountEq],				0) as [LoanPostponedAmountEq] ,
	isnull([LoanDoubtfullAmountEq],				0) as [LoanDoubtfullAmountEq] ,
	isnull([LoanDelayedPenaltyAmountEq],		0) as [LoanDelayedPenaltyAmountEq] ,
	isnull([InternalLCDoubtfullAmountEq],		0) as [InternalLCDoubtfullAmountEq] ,
	isnull([InternalLCDebtorAmountEq],			0) as [InternalLCDebtorAmountEq] ,
	isnull([InternalLCDelayedPenaltyAmountEq],	0) as [InternalLCDelayedPenaltyAmountEq] ,
	isnull([InternalLCCurrentAmountEq],			0) as [InternalLCCurrentAmountEq] ,
	isnull([GuaranteeDoubtfullAmountEq],		0) as [GuaranteeDoubtfullAmountEq] ,
	isnull([GuaranteeDebtorAmountEq],			0) as [GuaranteeDebtorAmountEq] ,
	isnull([GuaranteeDelayedPenaltyAmountEq],	0) as [GuaranteeDelayedPenaltyAmountEq] ,
	isnull([GuaranteeCurrentAmountEq],			0) as [GuaranteeCurrentAmountEq] ,
	isnull([InDirectCommitmentsAmountEq],		0) as [InDirectCommitmentsAmountEq] ,
	isnull([LoanSandoghToseeMeliAmountEq],		0) as [LoanSandoghToseeMeliAmountEq] ,
	isnull([TotalAssuranceAmountEq],			0) as [TotalAssuranceAmountEq] ,
	[CalculateDate], 
	[PersianCalculateDate] ,
	isnull(PrepaymentAmountCurrentLc,			0) as PrepaymentAmountCurrentLc ,
	isnull(PrepaymentAmountDebtorLc,			0) as PrepaymentAmountDebtorLc ,
	isnull(PrepaymentAmountMashkookLc,			0) as PrepaymentAmountMashkookLc ,
	isnull(PrepaymentAmountCurrentGa,			0) as PrepaymentAmountCurrentGa ,
	isnull(PrepaymentAmountDebtorGa,			0) as PrepaymentAmountDebtorGa ,
	isnull(PrepaymentAmountMashkookGa,			0) as PrepaymentAmountMashkookGa ,
	stockprice

from  ETL_TMP_InquiryReportData


  
  ------CalculationTime
  
  delete from CalculationTime where cast(CalculationDate as date) =@CalculateDate 
  and PackageName=N'InquiryReportData'



---- Insert into  CalculationTime

insert into CalculationTime ( [Guid]
      ,[CreationDate]
      ,[LastModifiedDate]
      ,[ModifiedBy]
      ,[CreatedBy]
      ,[CalculationDate]
   ,PackageName
   
   )  
   select NEWID() as Guid,

sysdatetime() as CreationDate,
SYSDATETIME() as LastmodifiedDate,
null,
null,
 @CalculateDate as Calculatetime,
  N'InquiryReportData' as PackageName



  --------------------------------Fill Flat Tables For CP REports


  EXEC [SP_CPReports_FillFlatTables] @CalculateDate


  
End
