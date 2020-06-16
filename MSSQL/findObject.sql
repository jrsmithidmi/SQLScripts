
SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'Triton',
	@definition VARCHAR(100) = 'vin10',
	@dbName VARCHAR(100),
	@objectName VARCHAR(200),
	@cur_TempCursor CURSOR
	

SET @strSQL = 
"
DECLARE cur_TempDatabases CURSOR FAST_FORWARD FOR
SELECT D.name
FROM master.sys.databases AS D
WHERE D.name LIKE '" + @serverName + "%'
"
EXEC(@strSQL)

OPEN cur_TempDatabases

FETCH NEXT FROM cur_TempDatabases INTO @dbName
	
WHILE @@FETCH_STATUS = 0
BEGIN			
	SET @strSQL =
	"	
	USE " + @dbName + " 
	SELECT sys.schemas.name + '.' + sys.objects.name as name, type_desc, definition, sys.objects.type, SM.object_id, '" + @dbName + "' AS dbName
	FROM sys.objects   
		INNER JOIN sys.schemas ON sys.objects.schema_id = sys.schemas.schema_id   
		INNER JOIN sys.sql_modules AS SM ON sys.objects.object_id = SM.object_id   
	WHERE sys.objects.is_ms_shipped = 0   
		AND definition LIKE '%" + @definition +"%'   
		AND sys.objects.type IN ('FN','P ','FN','IF','TF','U ','V','TR') 
	ORDER BY sys.objects.name, sys.objects.schema_id 
	"		
	EXEC(@strSQL)
	FETCH NEXT FROM cur_TempDatabases INTO @dbName
END

CLOSE cur_TempDatabases
DEALLOCATE cur_TempDatabases
