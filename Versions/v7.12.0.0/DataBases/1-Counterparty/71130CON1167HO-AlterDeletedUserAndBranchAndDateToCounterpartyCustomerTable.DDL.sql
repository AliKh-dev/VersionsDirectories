use Counterparty;
Go

if not exists (Select * From sys.all_columns Where object_id(N'CounterpartyCustomer')=object_id and name=N'ChangeStatusByBranchId')
	ALTER TABLE dbo.CounterpartyCustomer ADD ChangeStatusByBranchId bigint;
else
	print N'از قبل اضافه شده است'
Go