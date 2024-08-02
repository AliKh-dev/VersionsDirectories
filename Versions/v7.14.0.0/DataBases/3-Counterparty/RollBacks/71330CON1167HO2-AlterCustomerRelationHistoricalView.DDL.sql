USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_CustomerRelationHistorical]    Script Date: 5/13/2024 10:44:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Elmira Javadpour
--CreatedDate: -
--Subject : --ویو جدول تاریخچه ای رابطه که در ان روابط خانوادگی کور نایده گرفته شده است 
--ChangeDescription 
--70101022EJ-14020129-NewRelatedPerson-ManualFamilyRelation   --- شرط اضافه شده است که روابط اتوماتیک  خانوادگی از سمت کور نادیده گرفته شود و  روابط  خانوادگی را از دستی های ایمپورت شده لود میکنه برای سپه اینا چنین کانفیگی خالی است عملا روابط خانوادگی اتومات مورد استفاده قرار میگیرند
--70501038EJ-14020508-AutomaticExtendEndDateSingle --- CoreRelationStatusId اضافه شدن فیلدهای مرتبط با تمدیدخودکارتایخ انقضا
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------


CREATE OR ALTER VIEW [dbo].[Vw_CustomerRelationHistorical]
AS
SELECT t1.[Id],
       t1.[Guid],
       t2.MainCustomerId AS [Customer1Id],
       t3.MainCustomerId AS [Customer2Id],
       [CustomerRelationTypeId],
       [StartDate],
       t1.CoreEndDate AS CoreEndDate,
       t1.EndDate AS EndDate,
       [RelationValue],
       [IsManual],
       t1.[RelationStatusID],
	   t1.CoreRelationStatusId ,
       [RemoveDate],
       [VotingRights],
       [ICustomer1],
       t1.[CreationDate],
       t1.[LastModifiedDate],
       t1.[ModifiedBy],
       [EtlLastChangeDate],
       [CustomerProfileId1],
       [CustomerProfileId2],
       [ApplicationId],
       [StatusCode],
       t1.[CreatedBy],
       [CoreId],
       [RelationExtractionTypeStr],
       t1.[TransactionDate],
       t1.[PersianTransactionDate],
       [RelationExtractionType],
       [DirectRelationValue],
       t4.MainCustomerId AS [Customer3Id],
       [PersonName],
       [PersonalCode],
       [BranchName],
       [BranchCode],
       [CreatedDate],
	   t1.IsNewManual,
	   t1.IsManualTransfered,
	   t1.CustomerRelationId,
	   t1.CreatorUserId,
	   t1.CreatorBranchId,

	   t1.[DeletedPersonalName],
       t1.[DeletedPersonalCode],
       t1.[DeletedBranchName],
       t1.[DeletedBranchCode],
       t1.[DeletedDate],
       t1.[PersianDeletedDate]
	  
	   
FROM [Common].[dbo].[CustomerRelationHistorical] t1
    JOIN Vw_SecondaryCustomerMapping t2
        ON t1.Customer1Id = t2.SecondaryCustomerId
    JOIN Vw_SecondaryCustomerMapping t3
        ON t1.Customer2Id = t3.SecondaryCustomerId
    LEFT JOIN Vw_SecondaryCustomerMapping t4
        ON t1.Customer3Id = t4.SecondaryCustomerId
WHERE (
          t1.IsManual = 0
          AND NOT EXISTS
(
    (SELECT v.Value AS ManualFamilyRelationIdsMustbeIgnored
     FROM OPENJSON(
          (
              SELECT Value
              FROM Vw_Config
              WHERE [Key] = 'cp:ManualFamilyRelationIdsMustbeIgnored'
          )
                  ) v
     WHERE v.Value = t1.CustomerRelationTypeId)
)
      )
      OR t1.IsManual = 1;

GO


