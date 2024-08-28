use AccountManagement
Go

declare @accessId bigint=(select top 1 Id from COM_ACC_Access where [key] = 'ccs.cp.customerrelation.searchmanual')
if  (@accessId is null or @accessId<1 )
	Begin
		declare @parentId bigint=(select top 1 Id   from COM_ACC_Access where [key] = 'ccs.cp.customerrelation.search')
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
								values(NEWID(),GETDATE(),GETDATE(),N'روابط ثبت شده','ccs.cp.customerrelation.searchmanual',@parentId,@applicationId,1,1,'la la-object-group',0,0,0)
					End
			End;
	End;
Else
	Begin
	  Print N'دسترسی برای صفحه روابط ثبت شده از قبل وجود دارد'  ;
	End;
Go
