SET NOCOUNT ON;

IF OBJECT_ID('tempdb..#tmpTables') IS NOT NULL
	DROP TABLE #tmpTables
	
CREATE TABLE #tmpTables
(
	id INT IDENTITY(1,1),
	tableName VARCHAR(100),
	schemaName VARCHAR(100),
	indexCount INT
)

DECLARE 
	@policyID INT,
	@cur_TempCursor CURSOR,
	@searchIndex nvarchar(100) = 'policyID',
	@notSearchTable NVARCHAR(100) = 'Policy',
	@tableName nvarchar(100),
	@schemaName NVARCHAR(100)

SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
SELECT O.name, S.name
FROM sys.sysobjects O 
	JOIN sys.tables ST ON O.ID = ST.object_id
	JOIN sys.schemas AS S ON S.schema_id = ST.schema_id
WHERE xtype = 'u'
	AND EXISTS(
		SELECT TOP 1 1 
		FROM sys.syscolumns
		WHERE id = O.id
			AND name = @searchIndex
	)
AND O.name <> @notSearchTable
ORDER BY O.name

OPEN @cur_TempCursor
FETCH NEXT FROM @cur_TempCursor INTO @tableName, @schemaName

WHILE @@FETCH_STATUS = 0
BEGIN
	WITH cte AS (
		SELECT i.name AS index_name, c.name      
		FROM sys.indexes i 
			LEFT JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
			LEFT JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
		WHERE ic.is_included_column != 1
		AND i.object_id = OBJECT_ID(@tableName)   
	), cte2 AS (
		SELECT c2.index_name, 
		STUFF((SELECT ',' + c.name
				FROM cte c
				WHERE c.index_name = c2.index_name
		FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 1, 1, '') [columns]
		FROM cte c2
		GROUP BY c2.index_name 
	)
	INSERT INTO #tmpTables (schemaName, tableName, indexCount)
	SELECT @schemaName, @tableName, COUNT(*)
	FROM cte2
	WHERE [columns] = @searchIndex
FETCH NEXT FROM @cur_TempCursor INTO @tableName, @schemaName
END 

CLOSE @cur_TempCursor
DEALLOCATE @cur_TempCursor

SELECT 'CREATE INDEX IX_' + tableName + '_' + @searchIndex + ' ON ' + TT.schemaName + '.' + TT.tableName + '('  + @searchIndex +  ') WITH (FILLFACTOR=100);
GO'
FROM #tmpTables AS TT
WHERE TT.indexCount = 0

