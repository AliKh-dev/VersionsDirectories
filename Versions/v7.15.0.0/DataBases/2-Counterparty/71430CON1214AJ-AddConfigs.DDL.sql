USE Counterparty

if(Not Exists(Select * from config Where [Key] = 'cp:StartDateIsRequired_RelationTypeIds'))
	Begin
		DECLARE @StartDateIsRequired_RelationTypeIds VARCHAR(MAX);
		SELECT @StartDateIsRequired_RelationTypeIds = '[' + SUBSTRING(
			(
				SELECT ',' + Convert(nvarchar(100),Id) AS [text()]
				FROM Vw_CustomerRelationType where Title in (N'همسر')
				FOR XML PATH('')
			), 2, 1000) + ']'

		INSERT INTO Config ([Guid], CreationDate, [Key], [Value], [Description], IsArray, Metadata, Visible)
					VALUES(NEWID(), GETDATE(), N'cp:StartDateIsRequired_RelationTypeIds', @StartDateIsRequired_RelationTypeIds, N'روابطی که تاریخ شروع آن ها الزامی است', 1, N'cp-cp', 1)
End
ELSE
		print '@StartDateIsRequired_RelationTypeIds exists'
		
		GO

if(Not Exists(Select * from config Where [Key] = 'cp:EndDateIsRequired_RelationTypeIds'))
	Begin
		DECLARE @EndDateIsRequired_RelationTypeIds VARCHAR(MAX);
		SELECT @EndDateIsRequired_RelationTypeIds = '[' + SUBSTRING(
			(
				SELECT ',' + Convert(nvarchar(100),Id) AS [text()]
				FROM Vw_CustomerRelationType where Title in (N'مدیر عامل',N'رئیس هیات مدیره',N'سهامدار',N'عضو هیات مدیره',N'نایب رئیس هیأت مدیره',N'قائم مقام مدیرعامل',N'عضو هیئت عامل')
				FOR XML PATH('')
			), 2, 1000) + ']'

		INSERT INTO Config ([Guid], CreationDate, [Key], [Value], [Description], IsArray, Metadata, Visible)
					VALUES(NEWID(), GETDATE(), N'cp:EndDateIsRequired_RelationTypeIds', @EndDateIsRequired_RelationTypeIds, N'روابطی که تاریخ پایان آن ها الزامی است', 1, N'cp-cp', 1)
End
ELSE
		print 'EndDateIsRequired_RelationTypeIds exists'

GO

if(Not Exists(Select * from config Where [Key] = 'cp:Customer1AndCustomer2MustIsReal_RelationTypeIds'))
	Begin
		DECLARE @Customer1AndCustomer2MustIsReal_RelationTypeIds VARCHAR(MAX);
		SELECT @Customer1AndCustomer2MustIsReal_RelationTypeIds = '[' + SUBSTRING(
			(
				SELECT ',' + Convert(nvarchar(100),Id) AS [text()]
				FROM Vw_CustomerRelationType where Title in (N'خواهر',N'دختر',N'پسر',N'همسر',N'پدر',N'مادر')
				FOR XML PATH('')
			), 2, 1000) + ']'

		INSERT INTO Config ([Guid], CreationDate, [Key], [Value], [Description], IsArray, Metadata, Visible)
					VALUES(NEWID(), GETDATE(), N'cp:Customer1AndCustomer2MustIsReal_RelationTypeIds', @Customer1AndCustomer2MustIsReal_RelationTypeIds, N'روابطی که باید دو طرف آن ها حقیقی باشد', 1, N'cp-cp', 1)
	END
	ELSE
		print 'Customer1AndCustomer2MustIsReal_RelationTypeIds exists'

GO

if(Not Exists(Select * from config Where [Key] = 'cp:Customer2MustIsLegal_RelationTypeIds'))
	Begin
		DECLARE @Customer2MustIsLegal_RelationTypeIds VARCHAR(MAX);
		SELECT @Customer2MustIsLegal_RelationTypeIds = '[' + SUBSTRING(
			(
				SELECT ',' + Convert(nvarchar(100),Id) AS [text()]
				FROM Vw_CustomerRelationType where Title in (N'مدیر عامل',N'رئیس هیات مدیره',N'سهامدار',N'عضو هیات مدیره',N'نایب رئیس هیأت مدیره',N'قائم مقام مدیرعامل', N'عضو هیئت عامل')
				FOR XML PATH('')
			), 2, 1000) + ']'

		INSERT INTO Config ([Guid], CreationDate, [Key], [Value], [Description], IsArray, Metadata, Visible)
							VALUES(NEWID(), GETDATE(), N'cp:Customer2MustIsLegal_RelationTypeIds', @Customer2MustIsLegal_RelationTypeIds, N'روابطی که باید طرف دوم حتما باید حقوقی باشد', 1, N'cp-cp', 1)
END
ELSE
		print 'Customer2MustIsLegal_RelationTypeIds exists'

GO

if(Not Exists(Select * from config Where [Key] = 'cp:VotingRightsOrRelationValueMustEntered_RelationTypeIds'))
	Begin
		DECLARE @VotingRightsOrRelationValueMustEntered_RelationTypeIds VARCHAR(MAX);
		SELECT @VotingRightsOrRelationValueMustEntered_RelationTypeIds = '[' + SUBSTRING(
			(
				SELECT ',' + Convert(nvarchar(100),Id) AS [text()]
				FROM Vw_CustomerRelationType where Title in (N'سهامدار')
				FOR XML PATH('')
			), 2, 1000) + ']'


		INSERT INTO Config ([Guid], CreationDate, [Key], [Value], [Description], IsArray, Metadata, Visible)
					VALUES(NEWID(), GETDATE(), N'cp:VotingRightsOrRelationValueMustEntered_RelationTypeIds', @VotingRightsOrRelationValueMustEntered_RelationTypeIds, N'روابطی که حداقل حق رای یا مقدار سهامداری وارد شده باشد', 1, N'cp-cp', 1)
	END

	ELSE
		print 'VotingRightsOrRelationValueMustEntered_RelationTypeIds exists'