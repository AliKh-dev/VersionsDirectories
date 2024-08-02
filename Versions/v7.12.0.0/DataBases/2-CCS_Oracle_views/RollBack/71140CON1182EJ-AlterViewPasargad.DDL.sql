USE [CCS_Oracle_views]
GO

/****** Object:  View [dbo].[Vw_DW_CounterPartyRule]    Script Date: 4/7/2024 3:32:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





--===============================================
ALTER VIEW [dbo].[Vw_DW_CounterPartyRule]
	AS
	SELECT 
		Id
		,Title
		,Code
		,[Description]
		, CAST([ShortTitle] AS NVARCHAR(2000)) AS [ShortTitle]
	FROM CounterParty..Vw_DW_CounterPartyRule


	/*select 
		Id
		,Title
		,Code
		,[Description]
		,Cast([ShortTitle] as nvarchar(2000)) as [ShortTitle]
	From CP_CounterPartyRule*/
--===============================================
GO


