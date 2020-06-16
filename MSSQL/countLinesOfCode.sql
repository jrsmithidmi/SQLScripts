SELECT
		 DB_NAME (DB_ID ()) AS 'DB_Name', SubQuery.type, COUNT (*) AS 'Object_Count', SUM (SubQuery.LinesOfCode) AS 'LinesOfCode'
FROM	 (
	SELECT
			 s.type, LEN (a.definition) - LEN (REPLACE (a.definition, CHAR (10), '')) AS 'LinesOfCode',
			 OBJECT_NAME (a.object_id)												  AS 'NameOfObject'
	FROM	 sys.all_sql_modules AS a
		JOIN sys.sysobjects		 AS s ON a.object_id = s.id
	-- AND xtype IN('TR', 'P', 'FN', 'IF', 'TF', 'V')
	WHERE	 OBJECTPROPERTY (a.object_id, 'IsMSShipped') = 0
) AS SubQuery
GROUP BY SubQuery.type;