USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_Customer]    Script Date: 6/18/2024 10:42:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Elmira Javadpour
--CreatedDate: -
--Subject : ویو مشتری 
--ChangeDescription 
--713601207EJ-14030229-FilterCustomerWithInvalidShahabCodeInSepah   -- فیلتر کردن مشتریانی که کد شهاب ندارند یا طولشان کمتر از 16 رقم هست و کد شهاب دایم ندارند در سپه
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------



CREATE VIEW [dbo].[Vw_Customer]
AS
with ShahabCodeStatusDaemId as (
select Value from  vw_config where [key]='com:ShahabCodeStatusDaemId'
),
LoanFormula as (
select Value from  vw_config where [key]='cp:LoanFormula'
)

SELECT  
	Id as [Id],  
	FirstName, 
	LastName, 
	FatherName,
	CustomerName, 
	CustomerNumber as  [CustomerNumber],  
	NationalCode as   NationalCode   , 
	NationalityId, 
	IsReal, 
	Age, 
	SexId, 
	SexName, 
	BirthDate, 
	PersianBirthDate, 
	BirthLocationName, 
	BirthCertificateNumber, 
	RegistrationNumber, 
	IsValid, 
    CreatorBranchId, 
	LegalRegistrationDate, 
	LegalPersianRegistrationDate, 
	LegalRegisterLocationName, 
	JobName, 
	MarriageId,
	MarriageName, 
	TransactionDate, 
	PersianTransactionDate, 
	IsSecondary,
	IsCoreCustomer,
	ShahabCode,
	ActivitySizeId,
	ImageFileId,
	CreatorBranchTitle,
	Guid, 
	CreationDate, 
	LastModifiedDate, 
	ModifiedBy,
	CreatedBy,
	RegistrationDate,
	RegisterLocationName,
	PersianCreateDate,
	LevelTitle,
	CellphoneNumber,
	InstitutionId,
	InstitutionName
FROM COMMON.dbo.Customer t1
where 
	(1 = (select value from LoanFormula)) or 
	(lenshahabcode = 16 and shahabcode is not null and ShahabCodeStatusId = (select value from ShahabCodeStatusDaemId) and 2 = (select value from LoanFormula))
GO


