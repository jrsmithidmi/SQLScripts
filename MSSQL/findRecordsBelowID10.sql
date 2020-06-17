SET QUOTED_IDENTIFIER OFF;

IF OBJECT_ID('tempdb..#TableInfo') IS NOT NULL DROP TABLE #TableInfo

CREATE TABLE #TableInfo(
	TableInfoID INT NOT NULL IDENTITY PRIMARY KEY,
	tableName VARCHAR(100),
	schemaName VARCHAR(100),
	recordCT INT
)

DECLARE 
	@policyID INT,
	@cur_TempCursor CURSOR,
	@tableName VARCHAR(100),
	@schemaName VARCHAR(100),
	@identityName VARCHAR(100),
	@SQL VARCHAR(MAX)
	
SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
SELECT T.name, S.name, C.name
FROM sys.tables AS T
	JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN sys.columns AS C ON C.object_id = T.object_id
WHERE C.is_identity = 1


OPEN @cur_TempCursor

FETCH NEXT FROM @cur_TempCursor INTO @tableName, @schemaName, @identityName
	
WHILE @@FETCH_STATUS = 0
BEGIN				
	SET @SQL = "SELECT '" + @tableName + "','" + @schemaName + "', COUNT(*) FROM " + @schemaName + "." + @tableName + " WHERE " + @identityName + " < 10"
	
	INSERT INTO #TableInfo (tableName, schemaName, recordCT)
	EXEC(@SQL)

	FETCH NEXT FROM @cur_TempCursor INTO @tableName, @schemaName, @identityName
END

CLOSE @cur_TempCursor
DEALLOCATE @cur_TempCursor

SELECT * 
FROM #TableInfo
WHERE recordCT > 0

SET QUOTED_IDENTIFIER ON;