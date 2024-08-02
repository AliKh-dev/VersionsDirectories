USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_CustomerRelation]    Script Date: 5/13/2024 10:10:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




--------------------------------------------------ChangeList-----------------------------

--CreatedBy : Elmira Javadpour
--CreatedDate: -
--Subject : --ویو جدول  رابطه  غیر تاریخچه ای که در ان روابط خانوادگی کور نایده گرفته شده است 
--ChangeDescription 
--70101022EJ-14020129-NewRelatedPerson-ManualFamilyRelation   --- شرط اضافه شده است که روابط اتوماتیک  خانوادگی از سمت کور نادیده گرفته شود و  روابط  خانوادگی را از دستی های ایمپورت شده لود میکنه برای سپه اینا چنین کانفیگی خالی است عملا روابط خانوادگی اتومات مورد استفاده قرار میگیرند
--70501038EJ-14020508-AutomaticExtendEndDateSingle --- CoreRelationStatusId اضافه شدن فیلدهای مرتبط با تمدیدخودکارتایخ انقضا
--73041093SA-14020730-Function پرفورمنس
--713301167HO-14030226-اضافه شدن فیلدهای مرتبط با کاربر و شعبه حذف کننده رابطه و تاریخ حذف رابطه
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------

CREATE OR ALTER VIEW [dbo].[Vw_CustomerRelation]
AS

SELECT t1.Id,
       t2.MainCustomerId AS [Customer1Id],
       t3.MainCustomerId AS [Customer2Id],
       t1.CustomerRelationTypeId,
       RelationValue,
       StartDate,
       t1.EndDate AS CoreEndDate,
       CASE
           WHEN t5.IsEffectiveInCalculation = 1 THEN
               t5.EndDate
           ELSE
               t1.EndDate
       END AS EndDate,
       t1.RelationStatusID AS CoreRelationStatusId,
       DirectRelationValue,
       IsManual,
       VotingRights,
       ApplicationId,
       t1.CoreId,
       RelationExtractionType,
       t1.Guid,
       t1.CreationDate,
       t1.LastModifiedDate,
       t1.ModifiedBy,
       t1.CreatedBy,
       t4.MainCustomerId AS [Customer3Id],
       [PersonName],
       [PersonalCode],
       [BranchName],
       [BranchCode],
       [CreatedDate],
	   t1.IsNewManual,
	   t1.IsManualTransfered,
	   t1.CreatorUserId,
	   t1.CreatorBranchId,
	   
      t1.[DeletedPersonalName],
      t1.[DeletedPersonalCode],
      t1.[DeletedBranchName],
      t1.[DeletedBranchCode],
      t1.[DeletedDate],
      t1.[PersianDeletedDate],
	   
	   CASE
           WHEN t5.IsEffectiveInCalculation = 1 THEN
               t5.RelationStatusID
           ELSE
               t1.RelationStatusID
       END AS RelationStatusID,

	   t1.ModifiedDate

FROM [Common].[dbo].[CustomerRelation] t1
    JOIN Vw_SecondaryCustomerMapping t2
        ON t1.Customer1Id = t2.SecondaryCustomerId
    JOIN Vw_SecondaryCustomerMapping t3
        ON t1.Customer2Id = t3.SecondaryCustomerId
    LEFT JOIN Vw_SecondaryCustomerMapping t4
        ON t1.Customer3Id = t4.SecondaryCustomerId
    LEFT JOIN CustomerRelationWithNewExpirationDate t5
        ON t5.CoreId = t1.CoreId
WHERE (
          t1.IsManual = 0
          AND  NOT EXISTS (
				SELECT v.Value
				FROM dbo.ManualFamilyRelationIdsMustbeIgnored() as v
				WHERE v.value=t1.CustomerRelationTypeId
            )
      )
      OR t1.IsManual = 1;
GO

IF NOT EXISTS (SELECT * FROM sys.fn_listextendedproperty(N'MS_DiagramPane1' , N'SCHEMA',N'dbo', N'VIEW',N'Vw_CustomerRelation', NULL,NULL))