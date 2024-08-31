USE [Counterparty]
GO

/****** Object:  View [dbo].[Vw_DW_CounterpartyRule]    Script Date: 4/7/2024 2:59:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[Vw_DW_CounterpartyRule]
	AS
	SELECT 
		Id
		,Title
		,Code
		,[Description]
		,[ShortTitle]
	FROM CounterPartyRule
--===============================================
GO


