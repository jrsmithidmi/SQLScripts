SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON;

DECLARE
	@columnName VARCHAR(100) = 'tranID',
	@idToSearch VARCHAR(100) = '747144',
	@sql VARCHAR(1000),
	@strSQL VARCHAR(MAX),
	@dbName VARCHAR(100),
	@tableName VARCHAR(200),
	@statementSQL VARCHAR(1500)
	
IF OBJECT_ID('tempdb..#tmpTableCount') IS NOT NULL DROP TABLE #tmpTableCount
CREATE TABLE #tmpTableCount(
	tmpTableCountID INT NOT NULL IDENTITY PRIMARY KEY,
	dbName VARCHAR(100),
	tableName VARCHAR(200),
	idCount INT
)

DECLARE databaseCur CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT D.name
FROM master.sys.databases AS D
WHERE D.name = 'PolicyExport'
ORDER BY D.name

OPEN databaseCur

FETCH NEXT FROM databaseCur INTO @dbName

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @statementSQL = "DECLARE tableCur CURSOR FAST_FORWARD FOR ";
	SET @sql = "
	SELECT	SCHEMA_NAME(t.schema_id) + '.' + t.name AS table_name
	FROM " + @dbName + ".sys.tables AS t
	JOIN " + @dbName + ".sys.columns c ON t.object_id = c.object_id
	WHERE	c.name = '" + @columnName + "'";	
	SET @statementSQL += @sql;
	EXEC(@statementSQL);
		
	OPEN tableCur

	FETCH NEXT FROM tableCur INTO @tableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
			SET @strSQL = "
			INSERT INTO #tmpTableCount(dbName, tableName, idCount)
			SELECT '" + @dbName + "','" + @tableName + "', COUNT(*)
			FROM " + @dbName + '.' + @tableName + "
			WHERE " +  @columnName + " = " + @idToSearch

			EXEC(@strSQL)

		FETCH NEXT FROM tableCur INTO @tableName    
	END

	CLOSE tableCur
	DEALLOCATE tableCur

    FETCH NEXT FROM databaseCur INTO @dbName    
END

CLOSE databaseCur
DEALLOCATE databaseCur

SELECT 'SELECT TOP 10 * FROM ' + TTC.tableName + ' WHERE ' + @columnName + ' =  ' + @idToSearch, TTC.idCount, TTC.tableName
FROM #tmpTableCount AS TTC
WHERE TTC.idCount <> 0