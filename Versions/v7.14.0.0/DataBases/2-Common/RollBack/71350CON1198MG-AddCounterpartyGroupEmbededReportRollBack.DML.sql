USE [COMMON]
GO

IF EXISTS (SELECT id FROM EmbededReports WHERE ReportCode = 'ccs-cp-er-cgir')
	delete  FROM EmbededReports WHERE ReportCode = 'ccs-cp-er-cgir'
else print N'deleted before'
go 