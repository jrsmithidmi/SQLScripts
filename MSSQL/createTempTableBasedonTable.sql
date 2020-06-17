DECLARE @tableName VARCHAR(50) = 'DriverAccident'

SELECT T.name AS 'TableName', NULL AS 'ColumnName',NULL AS 'ColumnID', NULL AS 'Max_Length', NULL AS 'DataTypeName', NULL AS 'DataPrecision', 
		NULL AS 'DataScale', NULL AS 'IsNullable', 'CREATE TABLE #Tmp' + T.name + '(' AS 'TableCreate'
FROM sys.tables T
WHERE T.name = @tableName
UNION
SELECT T.name, C.name, 0, C.max_length, T2.name, T2.precision, T2.scale, C.is_nullable,
	+ '	' + 'tmp' + UPPER(LEFT(C.name,1)) + SUBSTRING(C.name, 2, 500) + ' ' +
		UPPER(CASE T2.name
			WHEN 'ADDRESS' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'CITYCOUNTY' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'CURRENCY' THEN 'DECIMAL(' + CAST(T2.precision AS VARCHAR(10)) + ',' + CAST(T2.scale AS VARCHAR(10)) + ')'
			WHEN 'EMAIL' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'NAME_Business' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'NAME_Person' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'PHONE_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'STATE_Abbrev' THEN 'CHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'TAXID_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'ZIP_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'varchar' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'nvarchar' THEN 'NVARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'char' THEN 'CHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'nchar' THEN 'NCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			ELSE T2.name
		END) + 
		CASE C.is_nullable
			WHEN 0 THEN ' NOT NULL'
			WHEN 1 THEN ' NULL'
			ELSE ''
		END +
		' IDENTITY (10,1),'
		AS columnCreate
FROM sys.tables T
	JOIN sys.columns C ON C.object_id = T.object_id
	JOIN sys.types T2 ON T2.user_type_id = C.user_type_id 
WHERE T.name = @tableName
AND C.is_identity = 1
UNION
SELECT T.name, C.name, C.column_id, C.max_length, T2.name, T2.precision, T2.scale, C.is_nullable,
	+ '	' + C.name + ' ' +
		UPPER(CASE T2.name
			WHEN 'ADDRESS' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'CITYCOUNTY' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'CURRENCY' THEN 'DECIMAL(' + CAST(T2.precision AS VARCHAR(10)) + ',' + CAST(T2.scale AS VARCHAR(10)) + ')'
			WHEN 'EMAIL' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'NAME_Business' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'NAME_Person' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'PHONE_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'STATE_Abbrev' THEN 'CHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'TAXID_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'ZIP_Formatted' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'varchar' THEN 'VARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'nvarchar' THEN 'NVARCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'char' THEN 'CHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			WHEN 'nchar' THEN 'NCHAR(' + CAST(C.max_length AS VARCHAR(10)) + ')'
			ELSE T2.name
		END) + 
		CASE C.is_nullable
			WHEN 0 THEN ' NOT NULL'
			WHEN 1 THEN ' NULL'
			ELSE ''
		END +
		CASE 
			WHEN C.column_id <> MAX(C.column_id) OVER() THEN ','
			ELSE '
)'
		END
		AS columnCreate
FROM sys.tables T
	JOIN sys.columns C ON C.object_id = T.object_id
	JOIN sys.types T2 ON T2.user_type_id = C.user_type_id 
WHERE T.name = @tableName
ORDER BY columnID


IF OBJECT_ID('tempdb..#tmpTableCreate') IS NOT NULL DROP TABLE #tmpTableCreate
CREATE TABLE #tmpTableCreate(
	ID INT NOT NULL IDENTITY (10,1),
	columnCreate varchar(1500) NULL
);

WITH cteColumnNum AS (
SELECT DISTINCT MAX(C.column_ID) OVER() / 5 AS 'One', (MAX(C.column_ID) OVER() / 5) * 2 AS 'Two', (MAX(C.column_ID) OVER() / 5) * 3 AS 'Three',
		(MAX(C.column_ID) OVER() / 5) * 4 AS 'Four', MAX(C.column_ID) OVER() AS 'MaxID'
FROM sys.tables T
	JOIN sys.columns C ON C.object_id = T.object_id
WHERE T.name = @tableName
)
INSERT INTO #tmpTableCreate(columnCreate)
SELECT 
	CASE 
		WHEN C.RowNum = 1
				THEN	(
								SELECT CASE WHEN C1.column_ID = 1 THEN '(' ELSE '' END + C1.name + CASE WHEN C1.column_id = (SELECT TOP 1 MaxID FROM cteColumnNum) THEN ')' ELSE ',' END
								FROM sys.columns C1
								WHERE C1.object_id = T.object_id
								AND C1.column_ID <= (SELECT TOP 1 one FROM cteColumnNum)
								FOR XML PATH('')
						)
		WHEN C.RowNum = 2
				THEN	(
								SELECT C1.name + CASE WHEN C1.column_id = (SELECT TOP 1 MaxID FROM cteColumnNum) THEN ')' ELSE ',' END
								FROM sys.columns C1
								WHERE C1.object_id = T.object_id
								AND C1.column_id > (SELECT TOP 1 One FROM cteColumnNum) AND C1.column_id <= (SELECT TOP 1 Two FROM cteColumnNum)
								FOR XML PATH('')
						)
		WHEN C.RowNum = 3
				THEN	(
								SELECT C1.name + CASE WHEN C1.column_id = (SELECT TOP 1 MaxID FROM cteColumnNum) THEN ')' ELSE ',' END
								FROM sys.columns C1
								WHERE C1.object_id = T.object_id
								AND C1.column_id > (SELECT TOP 1 Two FROM cteColumnNum) AND C1.column_id <= (SELECT TOP 1 Three FROM cteColumnNum)
								FOR XML PATH('')
						)
		WHEN C.RowNum = 4
				THEN	(
								SELECT C1.name + CASE WHEN C1.column_id = (SELECT TOP 1 MaxID FROM cteColumnNum) THEN ')' ELSE ',' END 
								FROM sys.columns C1
								WHERE C1.object_id = T.object_id
								AND C1.column_id > (SELECT TOP 1 Three FROM cteColumnNum) AND C1.column_id <= (SELECT TOP 1 Four FROM cteColumnNum)
								FOR XML PATH('')
						)
		WHEN C.RowNum = 5
				THEN	(
								SELECT C1.name + CASE WHEN C1.column_id = (SELECT TOP 1 MaxID FROM cteColumnNum) THEN ')' ELSE ',' END
								FROM sys.columns C1
								WHERE C1.object_id = T.object_id
								AND C1.column_ID > (SELECT TOP 1 Four FROM cteColumnNum)
								FOR XML PATH('')
						)
	END	AS columnCreate
FROM sys.tables T
	CROSS APPLY (
			SELECT 1 AS RowNum
			UNION
			SELECT 2 AS RowNum
			UNION
			SELECT 3 AS RowNum
			UNION
			SELECT 4 AS RowNum
			UNION
			SELECT 5 AS RowNum
			) AS C
WHERE T.name = @tableName;




SELECT 0 AS ID, 'INSERT INTO #Tmp' + T.name AS 'TableCreate'
FROM sys.tables T
WHERE T.name = @tableName
UNION
SELECT ID, '	' + columnCreate
FROM #tmpTableCreate
UNION
SELECT 15 AS ID, 'SELECT ' AS 'TableCreate'
FROM sys.tables T
WHERE T.name = @tableName
UNION
SELECT ID * 2, '	' + REPLACE(REPLACE(columnCreate,'(',''),')','')
FROM #tmpTableCreate
UNION
SELECT 30 AS ID, 'FROM ' + (SELECT CASE CHARINDEX('_',DB_NAME()) WHEN 0 THEN DB_NAME() ELSE SUBSTRING(DB_NAME(),1,CHARINDEX('_',DB_NAME())-1) END) + '..' + T.name + ' WITH(NOLOCK)' + ' 
WHERE ' + C.name + ' = @' + C.name AS 'TableCreate'
FROM sys.tables T
	JOIN sys.columns C ON C.object_id = T.object_id
WHERE T.name = @tableName
AND C.is_identity = 1
ORDER BY ID