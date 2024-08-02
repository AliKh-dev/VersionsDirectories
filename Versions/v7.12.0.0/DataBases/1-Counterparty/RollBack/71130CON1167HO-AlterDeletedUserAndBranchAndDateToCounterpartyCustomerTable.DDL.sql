use Counterparty;
Go

if exists (Select * From sys.all_columns Where object_id(N'CounterpartyCustomer')=object_id and name=N'ChangeStatusByBranchId')
	ALTER TABLE dbo.CounterpartyCustomer DROP ChangeStatusByBranchId;
else
	print N'از قبل اضافه نشده است'
Go