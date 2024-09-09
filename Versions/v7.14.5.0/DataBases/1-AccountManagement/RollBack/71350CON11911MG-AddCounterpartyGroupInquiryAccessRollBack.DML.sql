use AccountManagement
--ExportV02AccessRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.exportv02') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.exportv02'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go
----------------------------------------------------------------------------------------------------------------------
--CounterpartyGroupHistoryExcelV02AccessRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyexcelv02') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyexcelv02'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go
----------------------------------------------------------------------------------------------------------------------
--CounterpartyGroupHistoryV02AccessRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyv02') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyv02'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go
-------------------------------------------------------------------------------------------------------------------------
--CounterpartyGroupInquiryIndexAccessRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.index') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.index'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go
-------------------------------------------------------------------------------------------------------------------------
--DownloadCounterpartyGroupInquiryFilesAccessRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.downloadcounterpartygroupinquiryfiles') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.downloadcounterpartygroupinquiryfiles'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go
--------------------------------------------------------------------------------------------------------------------------
--ComonApiSearchUsersRollBack
if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.commonapi.searchusers') 
	begin 
		delete from COM_ACC_Access where [key] = 'ccs.cp.commonapi.searchusers'
	end;
else
	begin 
		Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go