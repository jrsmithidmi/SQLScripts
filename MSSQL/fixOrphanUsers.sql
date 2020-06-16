SET QUOTED_IDENTIFIER OFF;
SET NOCOUNT ON;
IF OBJECT_ID('tempdb..#tmpLogin') IS NOT NULL DROP TABLE #tmpLogin
CREATE TABLE #tmpLogin (
	tmpLoginID INT NOT NULL IDENTITY PRIMARY KEY,
	userName VARCHAR(250) NULL,
	userSID VARBINARY(MAX)
)

DECLARE @serverName VARCHAR(100) = 'Aggressive',
		@dbName VARCHAR(100),
		@strSQL VARCHAR(MAX),
		@userSQL VARCHAR(MAX),
		@userName VARCHAR(100),
		@cur_TempCursor CURSOR

/* declare variables */
DECLARE @variable INT

DECLARE loopDatabases CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT D.[name]
FROM sys.databases AS D
WHERE D.[name] LIKE @serverName + '%'

OPEN loopDatabases

FETCH NEXT FROM loopDatabases INTO @dbName

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @userSQL = "EXEC " + @dbname + ".dbo.sp_change_users_login @Action='Report';"
	--PRINT @userSQL
	INSERT INTO #tmpLogin (userName, userSID)
	EXEC(@userSQL)
	
	SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
	SELECT userName
	FROM #tmpLogin
	WHERE userName LIKE @serverName + '_%'

	OPEN @cur_TempCursor

	FETCH NEXT FROM @cur_TempCursor INTO @userName
	
	WHILE @@FETCH_STATUS = 0
	BEGIN				
		IF EXISTS(SELECT 1 FROM master.sys.sql_logins WHERE name = @username)
		BEGIN	
			SET @strSQL = "EXEC " + @dbName + ".dbo.sp_change_users_login @Action='update_one', @UserNamePattern='" + @username + "', @LoginName='" + @username + "'";
			EXEC(@strSQL)
			PRINT @strSQL + " user is fixed!"
		END

		FETCH NEXT FROM @cur_TempCursor INTO @userName
	END

	CLOSE @cur_TempCursor
	DEALLOCATE @cur_TempCursor

	TRUNCATE TABLE #tmpLogin
    FETCH NEXT FROM loopDatabases INTO @dbName
END

CLOSE loopDatabases
DEALLOCATE loopDatabases

PRINT 'All Finished!'


/*  Use if you need to fix a single orphan */
/*
EXEC ARIC..sp_change_users_login @Action='update_one', @UserNamePattern='aric_95930150', @LoginName='aric_95930150'
EXEC ARIC_Rate..sp_change_users_login @Action='update_one', @UserNamePattern='aric_95930150', @LoginName='aric_95930150'
EXEC ARIC_LOg..sp_change_users_login @Action='update_one', @UserNamePattern='aric_95930150', @LoginName='aric_95930150'
EXEC ARIC_QuoteImport..sp_change_users_login @Action='update_one', @UserNamePattern='aric_95930150', @LoginName='aric_95930150'
EXEC ARIC_Import..sp_change_users_login @Action='update_one', @UserNamePattern='aric_95930150', @LoginName='aric_95930150'
*/
