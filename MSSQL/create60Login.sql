--SET mainDB to be used
USE Hoaic60
GO

BEGIN TRY

	DECLARE 
		@listStr VARCHAR(MAX),
		@sql VARCHAR(MAX),
		@newUserID INT,
		@sp_adduser VARCHAR(MAX),
		@sp_addrolemember VARCHAR(MAX),
		@dbName VARCHAR(50) = 'HOAIC60',  --set DB
		@newUserName VARCHAR(50) = '',  --new user name
		@newUserPassword VARCHAR(50) = 'Testing123!' --new user password

	SET @dbName = RTRIM(LTRIM(@dbName))
	SET @newUserName = RTRIM(LTRIM(@newUserName))
	SET @newUserPassword = RTRIM(LTRIM(@newUserPassword))

	IF LEN(@newUserPassword) < 8
	BEGIN
		PRINT 'NEED A LONGER PASSWORD';
		RETURN;
	END

	IF LEN(@newUserName) <= 3
	BEGIN
		PRINT 'NEED A LONGER USERNAME';
		RETURN;
	END

	IF NOT EXISTS(SELECT * FROM sys.sysdatabases AS S WHERE S.name = @dbName)
	BEGIN
		PRINT 'DATABASE DOES NOT EXISTS!';
		RETURN;
	END

	IF NOT EXISTS(SELECT * FROM dbo.Users AS U WHERE U.usersID = 3)
	BEGIN
		PRINT 'UsersID 3 does not exist in the users table.  User setup failed.';
		RETURN;
	END

	IF EXISTS(SELECT * FROM sys.syslogins AS S WHERE S.name = @dbName + '_' + @newUserName) OR
		EXISTS(SELECT * FROM dbo.Users AS U WHERE U.username = @dbName + '_' + @newUserName)
	BEGIN
		PRINT 'USER EXISTS!'
		RETURN;
	END

	BEGIN TRANSACTION

	BEGIN TRY
		SET @sql = 'CREATE LOGIN [' + @dbName + '_' + @newUserName +'] WITH PASSWORD=N''' + @newUserPassword + ''', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
		PRINT @sql
		EXEC(@sql)
		COMMIT;
	END TRY
	BEGIN CATCH
		ROLLBACK;
		RETURN;
	END CATCH


	SELECT @listStr = COALESCE(@listStr+',' ,'') + C.name
	FROM sys.tables AS T
		JOIN sys.schemas AS S ON S.schema_id = T.schema_id
		JOIN sys.columns AS C ON C.object_id = T.object_id
	WHERE T.name = 'Users'
		AND C.is_identity = 0

	SET @sql = 'INSERT INTO dbo.Users(' + @listStr + ')';
	SET @sql = @sql + ' SELECT ' + REPLACE(REPLACE(REPLACE(@listStr, 'username', '''' + @dbName + '_' + @newUserName + ''''), 'enPassword' ,''''''), 'loginType', '2') + ' FROM dbo.Users AS U WHERE U.usersID = 3;'

	--PRINT @sql
	EXEC(@sql)

	SELECT @newUserID = U.usersID
	FROM dbo.Users AS U
	WHERE U.username = @dbName + '_' + @newUserName

	IF @newUserID IS NULL
	BEGIN
		PRINT 'User insert failed';
		RETURN;
	END
	--PRINT @newUserID

	UPDATE dbo.Users SET Users.permissionUsersID = @newUserID
	WHERE Users.usersID = @newUserID

	DECLARE 
		@databaseToName VARCHAR(100),
		@cur_TempCursor CURSOR
	
	SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
	SELECT D.name
	FROM sys.databases AS D
	WHERE D.name LIKE @dbName + '%'

	OPEN @cur_TempCursor

	FETCH NEXT FROM @cur_TempCursor INTO @databaseToName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN				

		SELECT	@sp_adduser = 'EXEC ' + @databaseToName + '..sp_adduser ' + '[' + @dbName +
				SUBSTRING(l.loginname, CHARINDEX('_', l.loginname, 1), 50) + ']',			
				@sp_addrolemember = 'EXEC ' + @databaseToName + '..sp_addrolemember PTS_User,' + '[' +  @dbName +
				SUBSTRING(l.loginname, CHARINDEX('_', l.loginname, 1), 50) + ']'
		FROM	master..syslogins l
		WHERE	l.isntname + l.isntgroup = 0
				AND l.name LIKE @dbName + '[_]%'
				AND EXISTS(SELECT 1 FROM dbo.Users AS U WHERE U.username = l.name AND U.usersID = @newUserID)

		--PRINT @sp_adduser
		--PRINT @sp_addrolemember		
		EXEC(@sp_adduser)
		EXEC(@sp_addrolemember)

		FETCH NEXT FROM @cur_TempCursor INTO @databaseToName
	END

	CLOSE @cur_TempCursor
	DEALLOCATE @cur_TempCursor

	IF (OBJECT_ID(N'tempdb..#tmpConfig') IS NOT NULL) DROP TABLE #tmpConfig ;
	CREATE TABLE #tmpConfig (
		schemaName VARCHAR(50),
		tableName VARCHAR(50)
	);

	IF (OBJECT_ID(N'tempdb..#tmpInsertTable') IS NOT NULL) DROP TABLE #tmpInsertTable ;
	CREATE TABLE #tmpInsertTable (
		insertString VARCHAR(MAX)
	);

	EXEC('
	INSERT INTO #tmpConfig ( schemaName, tableName )
	SELECT S.name, T.name
	FROM ' + @dbName + '_Config.sys.tables AS T
		JOIN ' + @dbName + '_Config.sys.schemas AS S ON S.schema_id = T.schema_id
		JOIN ' + @dbName + '_Config.sys.columns AS C ON C.object_id = T.object_id
	WHERE C.name = ''usersID''
	AND T.name NOT LIKE ''%Log%''
	')

	IF (SELECT CURSOR_STATUS('global','userPermissions')) = 1
	BEGIN
		CLOSE userPermissions
		DEALLOCATE userPermissions
	END

	DECLARE @schemaName VARCHAR(50),
			@tableName VARCHAR(50),
			@tableColumns VARCHAR(MAX)

	DECLARE userPermissions CURSOR FAST_FORWARD READ_ONLY FOR 
	SELECT TC.schemaName, TC.tableName 
	FROM #tmpConfig AS TC

	OPEN userPermissions

	FETCH NEXT FROM userPermissions INTO @schemaName, @tableName

	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC('
		DECLARE @listPermissions VARCHAR(MAX)

		SELECT @listPermissions = COALESCE(@listPermissions + '','' ,'''') + C.name
		FROM ' + @dbName + '_Config.sys.tables AS T
			JOIN ' + @dbName + '_Config.sys.schemas AS S ON S.schema_id = T.schema_id
			JOIN ' + @dbName + '_Config.sys.columns AS C ON C.object_id = T.object_id
		WHERE T.name = ''' + @tableName + '''' +
			' AND S.name = ''' + @schemaName + '''' +
			' AND C.is_identity = 0

		INSERT INTO #tmpInsertTable ( insertString )
		VALUES(@listPermissions)
		')
	   	  
		SELECT @tableColumns = T.insertString
		FROM #tmpInsertTable AS T

		SET @sql = 'INSERT INTO ' + @dbName + '_Config.' + @schemaName + '.' + @tableName + '(' + @tableColumns + ')';
		SET @sql = @sql + ' SELECT DISTINCT ' + REPLACE(@tableColumns,'usersID', @newUserID) + ' FROM ' + @dbName + '_Config.' + @schemaName + '.' + @tableName + ' AS U WHERE U.usersID = 3;'
	
		PRINT @sql
		EXEC(@sql)
	
		TRUNCATE TABLE #tmpInsertTable

		FETCH NEXT FROM userPermissions INTO @schemaName, @tableName
	END

	CLOSE userPermissions
	DEALLOCATE userPermissions
END TRY
BEGIN CATCH
	SELECT 
		SYSDATETIME() AS SystemDate,
		ERROR_NUMBER() AS ErrorNumber,
		ERROR_SEVERITY() AS ErrorSeverity,
		ERROR_STATE() AS ErrorState,
		ERROR_PROCEDURE() AS ErrorProcedure,
		ERROR_LINE() AS ErrorLine,
		ERROR_MESSAGE() AS ErrorMessage
END CATCH
