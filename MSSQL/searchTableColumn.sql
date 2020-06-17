SELECT
	t.name AS 'table_name', SCHEMA_NAME (t.schema_id) AS 'schema_name', c.name AS 'column_name',
	'SELECT DISTINCT [' + c.name + '] FROM ' + SCHEMA_NAME (t.schema_id) + '.' + t.name
FROM sys.tables  AS t
	INNER JOIN sys.columns AS c ON t.object_id = c.object_id
WHERE c.name LIKE '%%'
ORDER BY schema_name, table_name;

SELECT
	t.name AS 'table_name', SCHEMA_NAME (t.schema_id) AS 'schema_name', c.name AS 'column_name',
	'SELECT COUNT(*) FROM ' + SCHEMA_NAME (t.schema_id) + '.' + t.name +
	' WHERE LEN(LTRIM(RTRIM([' + c.name + '])) > 0' 
FROM sys.tables  AS t
	INNER JOIN sys.columns AS c ON t.object_id = c.object_id
WHERE c.name LIKE '%%'
ORDER BY schema_name, table_name;