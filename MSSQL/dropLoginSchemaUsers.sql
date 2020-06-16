SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'Hearth',
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
	PRINT 'Dropped Schema for ' + @dbName + '!!!!!!'
	SET @strSQL =
	"	
	USE " + @dbName + " 
	DECLARE @variable VARCHAR(100)

	DECLARE dropUsers CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 'drop schema [' + S.name + ']' 
	from sys.schemas AS S
	WHERE S.name like 'Windhaven%'

	OPEN dropUsers

	FETCH NEXT FROM dropUsers INTO @variable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@variable)
		FETCH NEXT FROM dropUsers INTO @variable
	END

	CLOSE dropUsers
	DEALLOCATE dropUsers
	"		
	EXEC(@strSQL)
	FETCH NEXT FROM cur_TempDatabases INTO @dbName
END

CLOSE cur_TempDatabases
DEALLOCATE cur_TempDatabases

GO

SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'Hearth',
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
	PRINT 'Dropped Users for ' + @dbName + '!!!!!!'
	SET @strSQL =
	"	
	USE " + @dbName + " 
	DECLARE @variable VARCHAR(100)

	DECLARE dropUsers CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 'drop USER [' + S.name + ']' 
	from sys.sysusers AS S
	WHERE S.name like 'Windhaven%'

	OPEN dropUsers

	FETCH NEXT FROM dropUsers INTO @variable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC (@variable)
		FETCH NEXT FROM dropUsers INTO @variable
	END

	CLOSE dropUsers
	DEALLOCATE dropUsers
	"		
	EXEC(@strSQL)
	FETCH NEXT FROM cur_TempDatabases INTO @dbName
END

CLOSE cur_TempDatabases
DEALLOCATE cur_TempDatabases

GO

SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'Embark',
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
	PRINT 'Dropped USER Script for ' + @dbName + '!!!!!!'
	SET @strSQL =
	"	
	USE " + @dbName + " 
	DECLARE @variable VARCHAR(100)

	DECLARE dropUsers CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 'ALTER USER [' + S.name + '] WITH NAME = [Embark_' + RTRIM(LTRIM(SUBSTRING(S.name, 11, LEN(S.name)))) + ']'
	FROM sys.sysusers AS S
	WHERE S.name LIKE 'Windhaven%'

	OPEN dropUsers

	FETCH NEXT FROM dropUsers INTO @variable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @variable
		EXEC (@variable)
		FETCH NEXT FROM dropUsers INTO @variable
	END

	CLOSE dropUsers
	DEALLOCATE dropUsers
	"		
	EXEC(@strSQL)
	FETCH NEXT FROM cur_TempDatabases INTO @dbName
END

CLOSE cur_TempDatabases
DEALLOCATE cur_TempDatabases

GO

/*DROP LOGINS*/
DECLARE @variable VARCHAR(100)

DECLARE dropUsers CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT 'DROP LOGIN [' + S.name + ']'
FROM sys.syslogins AS S
WHERE S.name LIKE 'Embark%'

OPEN dropUsers

FETCH NEXT FROM dropUsers INTO @variable

WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT @variable
	EXEC (@variable)
	FETCH NEXT FROM dropUsers INTO @variable
END

CLOSE dropUsers
DEALLOCATE dropUsers
