use AccountManagement
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.customerrelation.searchmanual') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.customerrelation.searchmanual'
	end;
else
	begin 
	  Print N'دسترسی برای از قبل وجود ندارد'  ;
	end;
Go