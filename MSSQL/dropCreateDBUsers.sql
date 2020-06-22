/* DROP SCHEMA & User */
SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON

DECLARE
	@strSQL NVARCHAR(MAX),
	@serverName VARCHAR(100) = 'WNIC',
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

	DECLARE dropSchema CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 'drop schema [' + S.name + ']' 
	from sys.schemas AS S
	WHERE S.name like '" + @serverName + "[_]%'

	OPEN dropSchema

	FETCH NEXT FROM dropSchema INTO @variable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @variable
		EXEC (@variable)
		FETCH NEXT FROM dropSchema INTO @variable
	END

	CLOSE dropSchema
	DEALLOCATE dropSchema
	"		
	EXEC(@strSQL)
	
	PRINT 'Dropped User for ' + @dbName + '!!!!!!'
	SET @strSQL =
	"	
	USE " + @dbName + " 
	DECLARE @variable VARCHAR(100)

	DECLARE dropUsers CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT 'drop USER [' + S.name + ']' 
	from sys.sysusers AS S
	WHERE S.name like '" + @serverName + "[_]%'

	OPEN dropUsers

	FETCH NEXT FROM dropUsers INTO @variable

	WHILE @@FETCH_STATUS = 0
	BEGIN
		--PRINT @variable
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

GO
/* CREATE SCRIPTS TO ADD USERS */

SET NOCOUNT ON;

DECLARE
	@databaseFromName VARCHAR(100) = 'WNIC',
	@loginName VARCHAR(100) -- = 'jrsmith';  --SET NULL FOR ALL USERS

DECLARE 
	@databaseToName VARCHAR(100),
	@cur_TempCursor CURSOR
	
SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
SELECT D.name
FROM sys.databases AS D
WHERE D.name LIKE @databaseFromName + '%'

OPEN @cur_TempCursor

FETCH NEXT FROM @cur_TempCursor INTO @databaseToName
	
WHILE @@FETCH_STATUS = 0
BEGIN				
	SELECT	'EXEC ' + @databaseToName + '..sp_adduser ' + '[' + @databaseFromName +
			SUBSTRING(l.loginname, CHARINDEX('_', l.loginname, 1), 50) + ']' + CHAR(10) + 
			'EXEC ' + @databaseToName + '..sp_addrolemember PTS_User,' + '[' +  @databaseFromName +
			SUBSTRING(l.loginname, CHARINDEX('_', l.loginname, 1), 50) + ']' + CHAR(10) + 
			'PRINT ''' + @databaseFromName + SUBSTRING(l.loginname, CHARINDEX('_', l.loginname, 1), 50) + ' is complete.''' + CHAR(10) + 'GO' + CHAR(10)
	FROM	master..syslogins l
	WHERE	l.isntname + l.isntgroup = 0
			AND l.name LIKE CASE
					WHEN @loginName IS NOT NULL THEN @databaseFromName + '_' + @loginName
					ELSE @databaseFromName + '[_]%'
				END

	PRINT '--- @@@@@@@ NEXT Database @@@@@@@ ---'

	FETCH NEXT FROM @cur_TempCursor INTO @databaseToName
END

CLOSE @cur_TempCursor
DEALLOCATE @cur_TempCursor

GO

/* RESET A LOGIN PASSWORD */
USE [master]
GO
ALTER LOGIN [WNIC_jrsmith] WITH PASSWORD=N'Test1234!'
GO
