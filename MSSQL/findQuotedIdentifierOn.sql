SELECT SCHEMA_NAME (s.schema_id) + '.' + s.name AS 'name', s.create_date, s.modify_date, 
	OBJECTPROPERTY (s.object_id, 'ExecIsQuotedIdentOn') AS 'IsQuotedIdentOn'
FROM	 sys.objects AS s
WHERE	 s.type IN ( 'P', 'TR', 'V', 'IF', 'FN', 'TF' )
		 AND OBJECTPROPERTY (s.object_id, 'ExecIsQuotedIdentOn') = 0
ORDER BY SCHEMA_NAME (s.schema_id) + '.' + s.name DESC;