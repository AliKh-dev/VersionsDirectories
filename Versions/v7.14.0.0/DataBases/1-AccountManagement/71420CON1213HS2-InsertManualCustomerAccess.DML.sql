use AccountManagement
Go

declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
if  (@accessId is null or @accessId<1 )
	Begin
		declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp')
		if(@parentId is null or @parentId = 0)
			begin; 
				throw 50004,N'دسترسی برای ذینفع یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId is null or @applicationId = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'صفحه مدیریت مشترهای ثبت شده','ccs.cp.manualCustomer.search',@parentId,@applicationId,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای صفحه مدیریت مشترهای ثبت شده از قبل وجود دارد'  ;
	End;
Go

declare @accessId2 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createRealCustomer')
if  (@accessId2 is null or @accessId2<1 )
	Begin
		declare @parentId2 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId2 is null or @parentId2 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!', 1
	
			end;
		else
			begin
				declare @applicationId2 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId2 is null or @applicationId2 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'ایجاد مشتری حقیقی جدید','ccs.cp.manualCustomer.createRealCustomer',@parentId2,@applicationId2,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای ایجاد مشتری حقیقی جدید از قبل وجود دارد'  ;
	End;
Go

declare @accessId3 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createLegalCustomer')
if  (@accessId3 is null or @accessId3<1 )
	Begin
		declare @parentId3 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId3 is null or @parentId3 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId3 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId3 is null or @applicationId3 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'ایجاد مشتری حقوقی جدید','ccs.cp.manualCustomer.createLegalCustomer',@parentId3,@applicationId3,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای ایجاد مشتری حقوقی جدید از قبل وجود دارد'  ;
	End;
Go

declare @accessId4 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editRealCustomer')
if  (@accessId4 is null or @accessId4<1 )
	Begin
		declare @parentId4 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId4 is null or @parentId4 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId4 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId4 is null or @applicationId4 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'ویرایش مشتری حقیقی','ccs.cp.manualCustomer.editRealCustomer',@parentId4,@applicationId4,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای ویرایش مشتری حقیقی از قبل وجود دارد'  ;
	End;
Go

declare @accessId5 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editLegalCustomer')
if  (@accessId5 is null or @accessId5<1 )
	Begin
		declare @parentId5 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId5 is null or @parentId5 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId5 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId5 is null or @applicationId5 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'ویرایش مشتری حقوقی','ccs.cp.manualCustomer.editLegalCustomer',@parentId5,@applicationId5,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای ویرایش مشتری حقوقی از قبل وجود دارد'  ;
	End;
Go

   declare @accessId5 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Excel')
if  (@accessId5 is null or @accessId5<1 )
	Begin
		declare @parentId5 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId5 is null or @parentId5 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId5 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId5 is null or @applicationId5 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'خروجی اکسل','ccs.cp.manualCustomer.Excel',@parentId5,@applicationId5,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای خروجی اکسل از قبل وجود دارد'  ;
	End;
Go

   declare @accessId5 bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Delete')
if  (@accessId5 is null or @accessId5<1 )
	Begin
		declare @parentId5 bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search')
		if(@parentId5 is null or @parentId5 = 0)
			begin; 
				throw 50004,N'دسترسی برای صفحه مدیریت مشترهای ثبت شده یافت نشد!',1
	
			end;
		else
			begin
				declare @applicationId5 bigint=(select top 1 ApplicationId from COM_ACC_Access where [key]='ccs.cp')
				if(@applicationId5 is null or @applicationId5 = 0)
					begin; 
						throw 50004,N'دسترسی برای اپلیکیشن یافت نشد!',1
					end;
				else
					begin
							insert into COM_ACC_Access([Guid],CreationDate,LastModifiedDate,Title,[Key],ParentId,ApplicationId,TypeId,IsEnable,DisplayCode,IsApi,IsSharedInSubsystems,CommonnessStatus)
								values(NEWID(),GETDATE(),GETDATE(),N'حذف مشتری','ccs.cp.manualCustomer.Delete',@parentId5,@applicationId5,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای حذف مشتری از قبل وجود دارد'  ;
	End;
Go