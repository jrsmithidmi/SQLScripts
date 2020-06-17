SET NOCOUNT ON;

DECLARE 
	@email VARCHAR(100) = 'n@n.com',
	@phone VARCHAR(100) = '111-222-3333';

SELECT 'UPDATE ' + S.name + '.' + T.name + ' SET ' + C.name + ' = ''' + @phone + ''';' + CHAR(10) + 'GO'
FROM sys.tables AS T
	JOIN sys.columns AS C ON T.object_id = C.object_id
	JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN sys.types AS T2 ON T2.user_type_id = C.user_type_id
WHERE c.name LIKE '%phone%'
AND C.name <> 'emailText'
AND T.name NOT LIKE '%log'
AND T.name NOT LIKE '%BAK%'
AND T2.name NOT IN ('tinyint','bit','int')
AND C.is_computed = 0
UNION ALL
SELECT 'UPDATE ' + S.name + '.' + T.name + ' SET ' + C.name + ' = ''' + @email + ''';' + CHAR(10) + 'GO'
FROM sys.tables AS T
	JOIN sys.columns AS C ON T.object_id = C.object_id
	JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN sys.types AS T2 ON T2.user_type_id = C.user_type_id
WHERE c.name LIKE '%email%'
AND C.name <> 'emailText'
AND T.name NOT LIKE '%log'
AND T.name NOT LIKE '%BAK%'
AND T2.name NOT IN ('tinyint','bit','int')
AND C.is_computed = 0