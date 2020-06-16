SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON;

DECLARE 
	@SQL NVARCHAR(MAX),
	@databaseOne VARCHAR(100) = 'TexasRanger',
	@databaseTwo VARCHAR(100) = 'TexasRanger',	
	@compareTableOne VARCHAR(100) = 'Vehicle',
	@schemaNameOne VARCHAR(100) = 'dbo',
	@compareTableTwo VARCHAR(100) = 'VehicleLog',
	@schemaNameTwo VARCHAR(100) = 'dbo'


SET @SQL = "
SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM " + @databaseOne + ".sys.tables AS T
	JOIN " + @databaseOne + ".sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN " + @databaseOne + ".sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM " + @databaseOne + ".sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM " + @databaseOne + ".sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = '" + @compareTableOne + "'
AND S.name = '" + @schemaNameOne + "'

EXCEPT

SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM " + @databaseTwo + ".sys.tables AS T
	JOIN " + @databaseTwo + ".sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN " + @databaseTwo + ".sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM " + @databaseTwo + ".sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM " + @databaseTwo + ".sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = '" + @compareTableTwo + "'
AND S.name = '" + @schemaNameTwo + "'
ORDER BY C.name
"

PRINT @SQL

EXEC (@SQL)

SET @SQL = "
SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM " + @databaseTwo + ".sys.tables AS T
	JOIN " + @databaseTwo + ".sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN " + @databaseTwo + ".sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM " + @databaseTwo + ".sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM " + @databaseTwo + ".sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = '" + @compareTableTwo + "'
AND S.name = '" + @schemaNameTwo + "'

EXCEPT

SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM " + @databaseOne + ".sys.tables AS T
	JOIN " + @databaseOne + ".sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN " + @databaseOne + ".sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM " + @databaseOne + ".sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM " + @databaseOne + ".sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = '" + @compareTableOne + "'
AND S.name = '" + @schemaNameOne + "'
ORDER BY C.name
"

EXEC (@SQL)


GO


/* Find missing table columns */
SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM HOAIC.sys.tables AS T
	JOIN HOAIC.sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN HOAIC.sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM HOAIC.sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM HOAIC.sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = 'Trans_Log' --Specific table here
AND S.name = 'dbo'

EXCEPT

SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM HOAIC60.sys.tables AS T
	JOIN HOAIC60.sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN HOAIC60.sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM HOAIC60.sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM HOAIC60.sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = 'Trans_Log' --Specific table here
AND S.name = 'dbo'
ORDER BY C.name




/* Display column and datatype */
SELECT	C.name,
		CASE T3.Name
			WHEN 'varchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nvarchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'char' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'nchar' THEN T3.Name + '(' + CAST(C.max_length as varchar(20)) + ')'
			WHEN 'decimal' THEN T3.Name + '(' + CAST(c.precision as varchar(20)) + ', ' + CAST(C.scale as varchar(5)) + ')'
			ELSE T3.Name
		END AS dataType
FROM HOAIC60.sys.tables AS T
	JOIN HOAIC60.sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN HOAIC60.sys.columns AS C ON C.object_id = T.object_id
	CROSS APPLY(SELECT * FROM HOAIC60.sys.types AS T2 WHERE T2.system_type_id = C.system_type_id AND T2.schema_id = 4) AS T3
	OUTER APPLY(SELECT * FROM HOAIC60.sys.default_constraints AS DC WHERE DC.object_id = C.default_object_id) AS DC1
WHERE T.name = 'Trans_Log' --Specific table here
AND S.name = 'dbo'
ORDER BY C.name