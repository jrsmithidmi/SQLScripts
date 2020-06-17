SELECT 'MAX(LEN(' + C.name + ')) AS ' + C.name + ',', C.name, C.max_length,T3.name
FROM sys.tables AS T
	JOIN sys.columns AS C ON C.object_id = T.object_id
	JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	CROSS APPLY(SELECT * FROM sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
WHERE T.name = 'Producer'
AND S.name = 'dbo'
AND T3.name IN ('varchar', 'char')