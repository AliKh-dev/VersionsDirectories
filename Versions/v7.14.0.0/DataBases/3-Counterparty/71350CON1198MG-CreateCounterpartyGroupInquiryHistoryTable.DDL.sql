﻿--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Mahdieh GolAlipour
--CreatedDate: 1403/03/12
--Subject : Create CounterpartyGroupInquiryHistory Table
--ChangeDescription 
--71350CON1198MG-14030310
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------
USE [Counterparty]
GO
/****** Object:  Table [dbo].[CounterpartyGroupInquiryHistory]    Script Date: 6/1/2024 8:50:16 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CounterpartyGroupInquiryHistory](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Guid] [uniqueidentifier] NULL,
	[CreationDate] [datetime] NULL,
	[LastModifiedDate] [datetime] NULL,
	[ModifiedBy] [bigint] NULL,
	[CreatedBy] [bigint] NULL,
	[UserBranchId] [bigint] NOT NULL,
	[FileId] [bigint] NULL,
	[UserId] [bigint] NOT NULL,
	[ReportDate] [datetime] NOT NULL,
	[CustomerId] [bigint] NOT NULL,
	[CustomerNumber] [bigint] NOT NULL,
	[CustomerName] [nvarchar](250) NOT NULL,
	[Message] [nvarchar](250) NOT NULL,
	[MessageCode] [int] NOT NULL,
	[NationalCode] [nvarchar](50) NOT NULL,
	[ReportName] [nvarchar](255) NULL,
 CONSTRAINT [PK_CounterpartyGroupInquiryHistory] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [FG_Defualt]
) ON [FG_Defualt]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_VisitorBranchId]  DEFAULT ((0)) FOR [UserBranchId]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_VisitorId]  DEFAULT ((0)) FOR [UserId]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_ReportDate]  DEFAULT (((2001)/(1))/(1)) FOR [ReportDate]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_CustomerId]  DEFAULT ((0)) FOR [CustomerId]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_CustomerNumber]  DEFAULT ((0)) FOR [CustomerNumber]
GO
ALTER TABLE [dbo].[CounterpartyGroupInquiryHistory] ADD  CONSTRAINT [DF_CounterpartyGroupInquiryHistory_NationalCode]  DEFAULT ((0)) FOR [NationalCode]
GO
