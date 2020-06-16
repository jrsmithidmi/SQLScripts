SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'HOAIC',
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
	PRINT 'Database - ' + @dbName + '!!!!!!'	
	SET @strSQL ="USE " + @dbName;

	SET @strSQL = @strSQL + 
	"	
	DECLARE c CURSOR FOR	
	SELECT S.name
	FROM sys.schemas AS S
	WHERE S.principal_id = 1;
	OPEN c;
	DECLARE @schemaName VARCHAR(500);
	DECLARE @strSQLInside VARCHAR(500);
	FETCH NEXT FROM c
	INTO @schemaName;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT 'Grant on ' +  @schemaName + '!!!!!!'	
		SET @strSQLInside = 'GRANT EXECUTE, SELECT, UPDATE, INSERT, DELETE ON SCHEMA::' + @schemaName + ' TO PTS_User;'

		BEGIN TRY
			EXEC (@strSQLInside);
		END TRY
		BEGIN CATCH
			PRINT @schemaName + ' ****************************** FAILED ******************************';
		END CATCH;
		FETCH NEXT FROM c
		INTO @schemaName;
	END;
	CLOSE c;
	DEALLOCATE c;
	"		
	EXEC(@strSQL)


	FETCH NEXT FROM cur_TempDatabases INTO @dbName
END

CLOSE cur_TempDatabases
DEALLOCATE cur_TempDatabases
