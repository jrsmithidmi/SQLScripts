SELECT	cols.column_id, 
	CASE 
		WHEN ty.name = 'int' THEN cols.Name + ' ' + UPPER(ty.name)
		WHEN ty.name = 'tinyint' THEN cols.Name + ' ' + UPPER(ty.name)
		WHEN ty.name = 'smallint' THEN cols.Name + ' ' + UPPER(ty.name)
		WHEN ty.name = 'varchar' THEN cols.Name + ' ' + UPPER(ty.name) + '(' + CAST(cols.max_length AS VARCHAR(5)) + ')'
		WHEN ty.name = 'char' THEN cols.Name + ' ' + UPPER(ty.name) + '(' + CAST(cols.max_length AS VARCHAR(5)) + ')'
		WHEN ty.name = 'smalldatetime' THEN cols.Name + ' ' + UPPER(ty.name)
		WHEN ty.name = 'bit' THEN cols.Name + ' ' + UPPER(ty.name)
		WHEN ty.name = 'decimal' THEN cols.Name + ' ' + UPPER(ty.name) + '(' + CAST(cols.[precision] AS VARCHAR(5)) + ',' + CAST(cols.scale AS VARCHAR(5)) + ')'
		ELSE 'ERROR'
	END + ',',
	cols.name, cols.max_length, cols.precision, cols.scale, ty.name
FROM	tempdb.sys.columns cols
JOIN	sys.types ty ON cols.system_type_id = ty.system_type_id
WHERE	cols.object_id = OBJECT_ID(N'tempdb..#Results')
AND TY.schema_id = 4
ORDER BY cols.column_id;