USE [Counterparty]
GO
/****** Object:  StoredProcedure [dbo].[SP_CalculateMacroLoanAndCommitmentReportOverConstantValue]    Script Date: 4/17/2024 3:57:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------

--LastModifiedDate : 1401/12/01 

--LastModifiedUser : Elmira Javadpour

---ChangeList : add part [SP_MacroLoanAndCommitmentReportOverConstantValueCancleOtherInprogressReports] for cancling other inprogress Reports

---------------



ALTER PROCEDURE  [dbo].[SP_CalculateMacroLoanAndCommitmentReportOverConstantValue] @CalculateDate Date='0001-01-01'
as
begin
BEGIN TRY
   if(@CalculateDate = '0001-01-01')
   Begin
     set @CalculateDate = DATEADD(day,-1,GetDate())
   end
   --==============================set  Global Variables==

   declare 
		@CP_MacroReportCurrancyCalculationRate decimal(38,4),
		@ConstantValueThresholdForDetectingMacroGroups  decimal(38,4),
		@BankName nvarchar(255),
		@BankId bigint,
		@PerisanCalculateDate nvarchar(255)

		select @ConstantValueThresholdForDetectingMacroGroups = [Value] from ConfigHistory where [Key]='cp:ConstantValueThresholdForDetectingMacroGroups' and EffectiveDate<=@CalculateDate and ISNULL(ExpirationDate,DateAdd(day,1,GetDate())) > @CalculateDate
		select @BankName=name ,@BankId= customerId  from Vw_CreditInstitueInfo where @CalculateDate >=EffectiveDate and @CalculateDate < isnull(ExpirationDate,dateadd(dd,1,getdate()))
		select @CP_MacroReportCurrancyCalculationRate = [Value] from ConfigHistory where [Key]='cp:MacroReportCurrancyCalculationRate' and EffectiveDate<=@CalculateDate and ISNULL(ExpirationDate,DateAdd(day,1,GetDate())) > @CalculateDate
		select @PerisanCalculateDate= P_DATE from Calendar where g_date=@CalculateDate



		select @ConstantValueThresholdForDetectingMacroGroups,@BankName,@CP_MacroReportCurrancyCalculationRate,@PerisanCalculateDate
	


	      --===============================================================if Inprogree Report is existed for this calculateDate , update it failed and then rollback that one and again calculateNew (Cancle the last inprogress one)
	    exec [SP_MacroLoanAndCommitmentReportOverConstantValueCancleOtherInprogressReports]  @CalculateDate = @CalculateDate
		


      --===============================================================
		insert into  MacroLoanAndCommitmentReportOverConstantValue ( [Guid], [BankName], [BankId],  [ConstantValueThreshold], [IsCalculationCompleted], [IsCounterPartyGroupCalculationCompleted], [ReportCurrancyCalculationRate], [CalculateDate], [PersianCalculateDate], [CreationDate], [LastModifiedDate], [ModifiedBy], [CreatedBy], [ExecutionStatus], [IsSucceed])
		values (NEWID(),@BankName,@BankId,@ConstantValueThresholdForDetectingMacroGroups,0,0,@CP_MacroReportCurrancyCalculationRate, @CalculateDate,@PerisanCalculateDate,@CalculateDate,null,null,null,'InProgress',0) 
		declare @MacroLoanAndCommitmentReportOverConstantValueId bigint = @@IDENTITY
		
		--log 0
		insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Start Step :  Creating MacroLoanAndCommitmentReportOverConstantValue  and  set Variables This Report Is Created By','Started',N'مرحله ساخت گزارش و ایجاد شناسه لازم برای ان و مقداردهی پارامترهای موردنیاز')
      --===============================================================
      
		exec SP_DeleteCurrentDayOfMacroLoanAndCommitmentReportOverConstantValueBeforeNewCalc @CalculateDate=@CalculateDate,@ConstantValueThresholdForDetectingMacroGroups=@ConstantValueThresholdForDetectingMacroGroups
		--log 1
		insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'SP_DeleteCurrentDayOfMacroLoanAndCommitmentReportOverConstantValueBeforeNewCalc!','executed',N'پاکسازی جداول گزارش تسهیلات وتعهدات  قبلی که برای روز مشابه محاسبه شده است با پارامترهای تکراری')
      --===============================================================
     

		exec [SP_FillMacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail] @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate
		-- log 2
	  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'SP_FillMacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail_WithOutAssurancefields!','executed',N'اس پی شیت ریز تسهیلات اجرا شد اما فیلدهای وثایق ان فعلا خالی است')
      

	     --===============================================================UpdateAssuranceFields
     
	 	exec [SP_UpdateAssuranceFields_MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail] @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate
		-- log 3
	  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[SP_UpdateAssuranceFields_MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail]!','executed',N'فیلدهای وثایق مرتبط با شیت تسهیلات بروز رسانی شد')
      --Log 4
	   insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Table MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail Filled with AssuranceFields Completely','executed',N'شیت ریز تسهیلات تکمیل شد')
      

      --=============================================================== Fill Sheet Commitments
        declare 
		

		@CP_NormalLCCalculationCoeffiecient decimal(38,4),
		@CP_LCCalculationCoeffiecientWhichHasNextDocument decimal(38,4),
		@CP_GuranteeRiskCoefficient decimal(38,4)
		
        select @CP_NormalLCCalculationCoeffiecient=cast([Value] as nvarchar(255))   from ConfigHistory where [key] like N'%cp:NormalLCCalculationCoeffiecient%' and @CalculateDate >=effectivedate and @CalculateDate < isnull(expirationdate,getdate())
		select @CP_LCCalculationCoeffiecientWhichHasNextDocument=[Value]    from ConfigHistory  where [key] like N'%cp:LCCalculationCoeffiecientWhichHasNextDocument%' and @CalculateDate >=effectivedate and @CalculateDate < isnull(expirationdate,getdate())
        select @CP_GuranteeRiskCoefficient=[Value]   from ConfigHistory where [key] like N'%cp:GuranteeRiskCoefficient%' and @CalculateDate >=effectivedate and @CalculateDate < isnull(expirationdate,getdate())
	

	-- log 5
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step Set  input Parmaters For Sp : SP_FillMacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail ','executed',N'مقداردهی پارامترهای وورودی اس پی شیت ریز تعهدات با موفقیت انجام شد');

		exec [SP_FillMacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail] @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate ,@CP_NormalLCCalculationCoeffiecient =@CP_NormalLCCalculationCoeffiecient,@CP_LCCalculationCoeffiecientWhichHasNextDocument =@CP_LCCalculationCoeffiecientWhichHasNextDocument,@CP_GuranteeRiskCoefficient =@CP_GuranteeRiskCoefficient
		-- log 5
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[SP_FillMacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail]! With Out Assurance Fields','executed',N'اس پی شیت تعهدات کامل اجرا شد- فیلد وثایق ان فعلا خالی است')
      --===============================================================Update AssuranceLCGuarantee

		exec SP_UpdateAssuranceFields_MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate
		---Log 6
			 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'SP_UpdateAssuranceFields_MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail!','executed',N'فیلدهای وثایق شیت تعهدات بروز شد')

		 -- log 7
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail]! With  Assurance Fields Filled completely','executed',N'شیت تعهدات تکمیل شده است')
      --==

		  --===============================================================

   
		exec [SP_FillMacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail] @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate
	    -- log 8
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[SP_FillMacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail]!','executed',N'اس پی جمع بندی گروه مشتری اجرا شد')

		
		 --===============================================================
   
		exec [SP_FillMacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail] @MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId , @CalculateDate = @CalculateDate,@ConstantValueThresholdForDetectingMacroGroups=@ConstantValueThresholdForDetectingMacroGroups
	    -- log 9
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[SP_FillMacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail]!','executed',N'اس پی جمع بندی گروه بندی ذینفع اجرا شد')

  
        --===============================================================

		 declare @Paramter nvarchar(max)	;
		with t1 as (
		select [Key]
          		  , Replace(Value,'"','') As Value
          		  , [Description]
				  , IsNull(IsArray,0) as IsArray
				  , EffectiveDate
				  ,ExpirationDate
        		from ConfigHistory
              		  where [key] in ('cp:ConstantValueThresholdForDetectingMacroGroups','cp:MacroReportCurrancyCalculationRate',N'cp:NormalLCCalculationCoeffiecient',N'cp:LCCalculationCoeffiecientWhichHasNextDocument',N'cp:GuranteeRiskCoefficient')
							and EffectiveDate<=@CalculateDate and ISNULL(ExpirationDate,DateAdd(day,1,GetDate())) > @CalculateDate
              		  ) ,
		t1Json (JsonParams) as (select * from t1 For json path)	
		select @Paramter = JsonParams from t1Json


		select @Paramter



		update t2 
			set
				[Parameters]=@Paramter
			from 
			MacroLoanAndCommitmentReportOverConstantValue t2
			where Id = @MacroLoanAndCommitmentReportOverConstantValueId

       --log 10
	  	 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step Update Field Parameters in MacroLoanAndCommitmentReportOverConstantValue ','executed',N'فیلد پارامترها بروز رسانی شد- این فیلد بیانگر این است که گزارش مذکور با چه پارامترهایی ساخته و اجرا شده است')

   --===============================================================update  MacroLoanAndCommitmentReportOverConstantValueId in  CounterPartyGroup

update CounterPartyGroup
   set MacroLoanAndCommitmentReportOverConstantValueId = t1.MacroLoanAndCommitmentReportOverConstantValueId
  from MacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail t1
 where IsMacroInGroup = 1
   and t1.MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId
   and t1.CounterPartyGroupId = CounterPartyGroup.Id

   --Log11
  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step update MacroGroups In counterPartyGroup tbl Completed!','executed',N'بروز رسانی گروه های کلان در جدول گروه ذینفع با موفقیت به اتمام رسید');


--===============================================================Update IsMacroInGroup INAllTbls
with 
  cte           as (select distinct CounterPartyGroupId from MacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail where  IsMacroInGroup = 1 and MacroLoanAndCommitmentReportOverConstantValueId= @MacroLoanAndCommitmentReportOverConstantValueId)
, CteCustomerId as (select t1.CustomerId, t1.CounterPartyGroupId from CounterPartyGroupCustomer t1 join cte t2 on t1.CounterPartyGroupId = t2.CounterPartyGroupId where cast(CalculateDate as date) = @CalculateDate)

, MAcroMacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail
                as (select t1.CustomerId
				         , t1.CounterPartyGroupId
						 , Id
					  from MacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail t1
					  join CteCustomerId t2 on t1.CustomerId = t2.CustomerId and t1.CounterPartyGroupId = t2.CounterPartyGroupId
					  where t1.MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId
)

update MacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail
   set   IsMacroInGroup = 1
  from MAcroMacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail t1
 where MacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail.MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId
   and t1.id = MacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail.id;

   -----Log 12
  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step update IsMacroInGroup In MacroLoanAndCommitmentReportOverConstantValueCustomerCounterpartyGroupDetail tbl Completed!','executed',N'فیلد IsMacroInGroup در جدول جمعبندی مشتری گروه ذینفع بروز شد-');




with
  cte           as (select distinct CounterPartyGroupId from MacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail where  IsMacroInGroup = 1 and MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId)
, CteCustomerId as (select t1.CustomerId, t1.CounterPartyGroupId from CounterPartyGroupCustomer t1 join cte t2 on t1.CounterPartyGroupId = t2.CounterPartyGroupId where cast(CalculateDate as date)= @CalculateDate)

, MAcroMacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail
                as (select t1.CustomerId
				         , Id
					  from MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail t1 join CteCustomerId t2 on t1.CustomerId = t2.CustomerId
					  where MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId
					  )

update MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail
   set   IsMacroInGroup = 1
  from MAcroMacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail t1 
 where MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail.MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId
   and t1.id = MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail.id;

    -----Log 13
  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step update IsMacroInGroup In MacroLoanAndCommitmentReportOverConstantValueCommitmentItemsDetail tbl !','executed',N'فیلد IsMacroInGroup در جدول شیت ریز تعهدات ذینفع بروز شد-');


with
  cte           as (select distinct CounterPartyGroupId from MacroLoanAndCommitmentReportOverConstantValueCounterpartyGroupDetail where  IsMacroInGroup = 1 and MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId)
, CteCustomerId as (select t1.CustomerId, t1.CounterPartyGroupId from CounterPartyGroupCustomer t1 join cte t2 on t1.CounterPartyGroupId = t2.CounterPartyGroupId where  cast(CalculateDate as date)= @CalculateDate)
, MAcroMacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail
                as (select t1.CustomerId
				         , Id
					  from MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail t1 join CteCustomerId t2 on t1.CustomerId=t2.CustomerId
					  
					  where MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId
					  )

update MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail
   set   IsMacroInGroup = 1
  from MAcroMacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail t1
 where MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail.MacroLoanAndCommitmentReportOverConstantValueId = @MacroLoanAndCommitmentReportOverConstantValueId
   and t1.id = MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail.id;

    -----Log 14
  insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'Step update IsMacroInGroup In MacroLoanAndCommitmentReportOverConstantValueLoanItemsDetail tbl !','executed',N'فیلد IsMacroInGroup در جدول شیت ریز تسهیلات بروز شد-');

      --===============================================================Log SuccessFull Run
	  	update MacroLoanAndCommitmentReportOverConstantValue set IsSucceed = 1 ,ExecutionStatus='Completed',IsCalculationCompleted=1,IsCounterPartyGroupCalculationCompleted=1 where id=@MacroLoanAndCommitmentReportOverConstantValueId
		--Log15
		 insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,' Step Update ExecutionStatus ,IsCalculationCompleted,IsCounterPartyGroupCalculationCompleted  !','executed',N'مرحله بروزرسانی وضعیت اجرا  و سایر فیلدهای مرتبط با تکمیل شدن محاسبه اجرا شد')


		 --log16
	   insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,' [SP_CalculateMacroLoanAndCommitmentReportOverConstantValue] Calculation Completed!','Completed',N'اس پی ساخت گزارش تسهیلات و تعهدات باالای هزار میلیارد ریال با موفقیت اجرا شد')

		 select * from MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog where MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId;

   END TRY
   BEGIN CATCH
   -- log 17
     insert into MacroLoanAndCommitmentReportOverConstantValueCalculationPipelineLog([Guid],MacroLoanAndCommitmentReportOverConstantValueId,Step,[State],[Description])
         values(NEWID(),@MacroLoanAndCommitmentReportOverConstantValueId,'[SP_CalculateMacroLoanAndCommitmentReportOverConstantValue] Calculation fail!','Failed',N'محاسبات  گزارش تسهیلات تعهدات کلان بالای هزار میلیارد به خطا خورد')
    
	update MacroLoanAndCommitmentReportOverConstantValue set ExecutionStatus='Failed' where Id = @MacroLoanAndCommitmentReportOverConstantValueId

   exec [SP_MacroLoanAndCommitmentReportOverConstantValueRoleBack] @MacroLoanAndCommitmentReportOverConstantValueId=@MacroLoanAndCommitmentReportOverConstantValueId  
   
   insert into MacroLoanAndCommitmentReportOverConstantValueCalculationErrors(
				MacroLoanAndCommitmentReportOverConstantValueId
				,Date
				,ErrorNumber
				,ErrorState
				,ErrorSeverity
				,ErrorProcedure
				,ErrorLine
				,ErrorMessage)
	 SELECT
	    @MacroLoanAndCommitmentReportOverConstantValueId as MacroLoanAndCommitmentReportOverConstantValueId,
	    GETDATE() as Date ,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_STATE() AS ErrorState,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage;
   END CATCH
end
