USE [Counterparty]
GO
/****** Object:  StoredProcedure [dbo].[SP_CustomerRelationWithNewExpirationDate_UpdateNotEffectiveExtendedRelationIfExactRelationIsInActiveFromCore_Sepah]    Script Date: 4/15/2024 10:55:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[SP_CustomerRelationWithNewExpirationDate_UpdateNotEffectiveExtendedRelationIfExactRelationIsInActiveFromCore_Sepah]
    @PersianTransactionDate NVARCHAR(255)
AS
BEGIN


    DECLARE @transactiondate DATE;


    SELECT @transactiondate = G_DATE
    FROM Calendar
    WHERE P_DATE = @PersianTransactionDate;

	
    DECLARE @Var_ActiveRelationStatusId BIGINT =
            (
                SELECT TOP 1
                       [Value]
                FROM dbo.Vw_ConfigHistory
                WHERE [Key] = 'com:ActiveRelationStatusId'  AND  @transactiondate >=EffectiveDate and @transactiondate < isnull(ExpirationDate,getdate()) 
            );



    UPDATE t5
    SET t5.IsEffectiveInCalculation=0
    FROM
    (

	----- اگر رکوردی  که ما  شناسایی کردیم  برای تمدید که قبلا در جدول روابط تمدید شده باشد و  از سمت کور عیر فعال شده باشد در نتیجه  تمدید ما نیز باید نادیده گرفته شود 
        SELECT t4.Id,
		0 AS IsEffectiveInCalculation
        FROM CustomerRelationWithNewExpirationDate t4
            JOIN dbo.Vw_CustomerRelationHistorical t1
                ON T4.CoreId = t1.CoreId 
        WHERE t1.TransactionDate = @transactiondate AND t1.CoreRelationStatusId <> @Var_ActiveRelationStatusId AND t1.CoreRelationStatusId <> t4.CoreRelationStatusId
             AND t4.IsEffectiveInCalculation = 1

       UNION all
--------اگر عینا رکوردی که ما تمدید کردیم خود به خود تاریخش تمدید شده بود از سمت کور بایستی رک.ورد مورد نظر ما ترجیحا ملاک کور باشد دیگر
SELECT t4.Id,
		0 AS IsEffectiveInCalculation
        FROM CustomerRelationWithNewExpirationDate t4
            JOIN dbo.Vw_CustomerRelationHistorical t1
                ON T4.CoreId = t1.CoreId 
        WHERE t1.TransactionDate = @transactiondate AND t1.CoreEndDate > @transactiondate AND t1.CoreRelationStatusId=@Var_ActiveRelationStatusId
             AND t4.IsEffectiveInCalculation = 1



    )a

	JOIN CustomerRelationWithNewExpirationDate t5 ON t5.id=a.id






END;






