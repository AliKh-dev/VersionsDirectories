﻿--------------------------------------------------ChangeList-----------------------------
--CreatedBy : Mahdieh GolAlipour
--CreatedDate: 1403/03/12
--Subject : Drop CounterpartyGroupInquiryHistory Table
--ChangeDescription 
--71350CON1198MG-14030310
--LastChangeDescription
--------------------------------------------------ChangeList-----------------------------
USE [Counterparty]
GO
/****** Object:  Table [dbo].[CounterpartyGroupInquiryHistory]    Script Date: 6/1/2024 8:50:58 AM ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[CounterpartyGroupInquiryHistory]') AND type in (N'U'))
DROP TABLE [dbo].[CounterpartyGroupInquiryHistory]
GO
