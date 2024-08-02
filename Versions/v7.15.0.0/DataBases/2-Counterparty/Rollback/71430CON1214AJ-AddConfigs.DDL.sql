USE Counterparty
delete config where [Key] = 'cp:EndDateIsRequired_RelationTypeIds'
delete config where [Key] = 'cp:Customer1AndCustomer2MustIsReal_RelationTypeIds'
delete config where [Key] = 'cp:VotingRightsOrRelationValueMustEntered_RelationTypeIds'
delete config where [Key] = 'cp:Customer2MustIsLegal_RelationTypeIds'
delete config where [Key] = 'cp:StartDateIsRequired_RelationTypeIds'
