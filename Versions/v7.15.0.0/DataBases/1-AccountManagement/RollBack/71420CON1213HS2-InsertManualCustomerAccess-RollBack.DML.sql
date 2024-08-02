use AccountManagement
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Delete') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Delete'
	end;
else
	begin 
	  Print N'دسترسی برای از قبل وجود ندارد'  ;
	end;
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Excel') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.Excel'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editLegalCustomer') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editLegalCustomer'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editRealCustomer') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.editRealCustomer'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go	

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createLegalCustomer') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createLegalCustomer'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createRealCustomer') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.createRealCustomer'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد'  ;
	end;
Go

if exists (select * from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search') 
	begin
		delete from COM_ACC_Access where [key] = 'ccs.cp.manualCustomer.search'
	end;
else
	begin 
	  Print N'دسترسی از قبل وجود ندارد' ;
	end;
Go