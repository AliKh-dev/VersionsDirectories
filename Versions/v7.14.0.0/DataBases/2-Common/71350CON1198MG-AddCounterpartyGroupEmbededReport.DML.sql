--به جای 
--{DatabaseName..ReportDB}
--نام دیتابیس گزارش ساز گذاشته شود


USE [COMMON]
GO

declare @existGuidForReport [uniqueidentifier]=(select top 1 Guid from {DatabaseName..ReportDB} where Title = N'استعلام گروه ذینفع واحد')

if  (@existGuidForReport is not null)
Begin
	IF NOT EXISTS (SELECT id FROM EmbededReports WHERE ReportCode = 'ccs-cp-er-cgir')
		insert into EmbededReports(Title,ReportGuid,ReportCode,AccessKey,ApplicationName,ReportType)
			values(N'استعلام گروه ذینفع واحد',@existGuidForReport,'ccs-cp-er-cgir','ccs.cp.counterpartygroup.counterpartygroupinquiry','CP','Reports')
	else print N'added before'
End;
Else
Begin
  Print N'گزارش از قبل وجود ندارد'  ;
End