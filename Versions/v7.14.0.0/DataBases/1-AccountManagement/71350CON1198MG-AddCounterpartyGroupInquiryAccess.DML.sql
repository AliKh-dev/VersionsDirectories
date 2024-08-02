use AccountManagement

--CounterpartyInquiryIndex
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.index')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'استعلام گروه ذینفع واحد','ccs.cp.counterpartygroupinquiry.index',@parentId,@applicationId,1,1,'la la-terminal',0,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End
------------------------------------------------------------------------------------------------------------------------------
--ExportV02Access
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.exportv02')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.index')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp.counterpartygroupinquiry.index" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp.counterpartygroupinquiry.index')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'استعلام گروه ذینفع واحد','ccs.cp.counterpartygroupinquiry.exportv02',@parentId,@applicationId,1,1,'la la-terminal',0,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End
--------------------------------------------------------------------------------------------------------------------------------------------------------
--CounterpartyHistoryV02Access
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyv02')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.index')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp.counterpartygroupinquiry.index" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp.counterpartygroupinquiry.index')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'تاریخچه استعلام گروه ذینفع واحد','ccs.cp.counterpartygroupinquiry.historyv02',@parentId,@applicationId,1,1,'la la-terminal',0,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End
--------------------------------------------------------------------------------------------------
--CounterpartyHistoryExcelV02Access
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyexcelv02')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyv02')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp.counterpartygroupinquiry.historyv02" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp.counterpartygroupinquiry.historyv02')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'فایل تاریخچه استعلام گروه ذینفع واحد','ccs.cp.counterpartygroupinquiry.historyexcelv02',@parentId,@applicationId,1,1,'la la-terminal',1,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End
----------------------------------------------------------------------------------------------------------------------
--DownloadCounterpartyGroupInquiryFilesAccess
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.downloadcounterpartygroupinquiryfiles')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.counterpartygroupinquiry.historyv02')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp.counterpartygroupinquiry.historyv02" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp.counterpartygroupinquiry.historyv02')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'دانلود فایل های استعلام گروه ذینفع واحد','ccs.cp.counterpartygroupinquiry.downloadcounterpartygroupinquiryfiles',@parentId,@applicationId,1,1,'la la-terminal',1,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End
-----------------------------------------------------------------------------------------------------------------------
--SearchUserApiAccess
declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.commonapi.searchusers')
if  (@accessId is null or @accessId<1 )
Begin
declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.customer.search')
	if(@parentId is null or @parentId = 0)
	begin; 
			throw 50004,'the access with "ccs.cp.customer.search" not Found!',1
	
	end;
	else
	begin
	  declare @applicationId bigint=(select top 1 ApplicationId   from COM_ACC_Access where [key]='ccs.cp.customer.search')
	
			if(@applicationId is null or @applicationId = 0)
			begin; 
					throw 50004,'applicationId not Valid',1
			end;
			else
			begin
			     insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
					   values(NEWID(),GETDATE(),GETDATE(),N'جست و جوی مشتریان شعبه','ccs.cp.commonapi.searchusers',@parentId,@applicationId,1,1,'la la-terminal',1,0,0)
			End
	End;
End;
Else
Begin
  Print N'دسترسی از قبل وجود دارد'  ;
End