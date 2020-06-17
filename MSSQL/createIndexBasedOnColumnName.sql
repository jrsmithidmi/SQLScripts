SET NOCOUNT ON;
SET QUOTED_IDENTIFIER OFF;

DECLARE
	@DBName VARCHAR(50) = 'SouthernTrust',
	@searchIndex nvarchar(100) = 'policyID';

IF OBJECT_ID('tempdb..#tmpTables') IS NOT NULL
	DROP TABLE #tmpTables

CREATE TABLE #tmpTables
(
	id INT IDENTITY(1,1),
	tableName VARCHAR(100),
	indexCount INT
)

DECLARE 	
	@tableName NVARCHAR(100),
	@schemaName NVARCHAR(100),
	@strSQL NVARCHAR(max)

SET @strSQL = 
"
DECLARE cur_TempCursor CURSOR FAST_FORWARD FOR
SELECT O.name, S.name
FROM " + @DBName + "..sysobjects O 
	JOIN " + @DBName + ".sys.tables ST ON O.ID = ST.object_id
	JOIN " + @DBName + ".sys.schemas AS S ON S.schema_id = ST.schema_id
WHERE xtype = 'u'
	AND EXISTS(
		SELECT TOP 1 1 
		FROM " + @DBName + "..syscolumns
		WHERE id = O.id
			AND name IN ( '" + @searchIndex + "'))	
ORDER BY O.name";

EXEC sp_executesql @strSQL

SET QUOTED_IDENTIFIER ON;

OPEN cur_TempCursor

FETCH NEXT FROM cur_TempCursor INTO @tableName, @schemaName
	
WHILE @@FETCH_STATUS = 0
BEGIN	

	SET QUOTED_IDENTIFIER OFF;

	SET @strSQL = 
	"			
		WITH cte AS (
			SELECT i.name AS index_name, c.name      
			FROM " + @DBName + ".sys.indexes i 
				LEFT JOIN " + @DBName + ".sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
				LEFT JOIN " + @DBName + ".sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
			WHERE ic.is_included_column != 1
			AND i.object_id = OBJECT_ID('" + @DBName + "." + @schemaName + "." + @tableName + "')   
		), cte2 AS (
			SELECT c2.index_name, 
			STUFF((SELECT ',' + c.name
					FROM cte c
					WHERE c.index_name = c2.index_name
			FOR XML PATH, TYPE).value('.[1]', 'nvarchar(max)'), 1, 1, '') [columns]
			FROM cte c2
			GROUP BY c2.index_name 
		)
		INSERT INTO #tmpTables (tableName, indexCount)
		SELECT '" + @schemaName + "." + @tableName + "', COUNT(*)
		FROM cte2
		WHERE [columns] = '" + @searchIndex + "'"

	EXEC sp_executesql @strSQL

	SET QUOTED_IDENTIFIER ON;

	FETCH NEXT FROM cur_TempCursor INTO @tableName, @schemaName
END

CLOSE cur_TempCursor
DEALLOCATE cur_TempCursor

SELECT *, 'CREATE INDEX [IX_' + tableName + '_' + @searchIndex +'] ON ' + tableName + '(' + @searchIndex + ') WITH (FILLFACTOR=100);
GO'
FROM #tmpTables AS TT
WHERE TT.indexCount = 0