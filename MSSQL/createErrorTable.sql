
/* declare variables */
DECLARE @dbName NVARCHAR(128),
	@synonymName VARCHAR(10) = 'SQLError',
	@tableName VARCHAR(10) = 'SQLError',
	@schemaName VARCHAR(10) = 'maint',
	@mainDBName NVARCHAR(128) = 'HOAIC',
	@sqlStatement NVARCHAR(MAX)

DECLARE cursor_Setup CURSOR FAST_FORWARD READ_ONLY FOR
SELECT D.name
FROM sys.databases AS D
WHERE D.name LIKE @mainDBName + '%'
AND D.name NOT LIKE '%60%'

OPEN cursor_Setup

FETCH NEXT FROM cursor_Setup INTO @dbName

WHILE @@FETCH_STATUS = 0
BEGIN

    BEGIN TRY		

		SET @sqlStatement = N'
			USE '+ QUOTENAME(@dbName) + '
			IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'+QuoteName(@SchemaName,'''') + ')
			EXEC (''CREATE SCHEMA ' + QUOTENAME(@SchemaName) + ''')' + '
			EXEC (''GRANT EXECUTE, UPDATE, INSERT, DELETE, SELECT ON SCHEMA::' + QUOTENAME(@SchemaName) + ' TO PTS_User'')'
							
		EXEC (@sqlStatement);

		IF @dbName = @mainDBName
		BEGIN
			SET @sqlStatement = N'
			USE '+ QUOTENAME(@dbName) + '
			IF NOT EXISTS(
				SELECT * 
				FROM sys.tables AS T
					JOIN sys.schemas AS S ON S.schema_id = T.schema_id
				WHERE T.name = ''' + @tableName + '''
				AND S.name = ''' + @schemaName + '''
			)
			CREATE TABLE ' + QUOTENAME(@schemaName) + '.' + QUOTENAME(@tableName)  + ' (
				sqlErrorID INT NOT NULL IDENTITY(10,1),
				errorDate DATETIME2(7) NOT NULL CONSTRAINT DF_errorDate DEFAULT(SYSDATETIME()),
				policyID INT,
				errorNumber INT,
				errorSeverity INT,
				errorState INT,
				errorProcedure NVARCHAR(128),
				errorLine INT,
				errorMessage NVARCHAR(4000),
				notes NVARCHAR(500)
			)
			';
			EXEC (@sqlStatement)
		END
					
		IF @dbName <> @mainDBName
		BEGIN
			SET @sqlStatement = N'
			USE '+ QUOTENAME(@dbName) + '
			IF NOT EXISTS (SELECT * FROM sys.synonyms WHERE name = N'+QuoteName(@synonymName,'''') + ')
			CREATE SYNONYM maint.SQLError FOR ' + QUOTENAME(@mainDBName) + '.maint.SQLError;'
			EXEC (@sqlStatement);
		END

	END TRY
	BEGIN CATCH
			SELECT
				@dbName AS '@dbName',
				ERROR_NUMBER() AS ErrorNumber,
				ERROR_SEVERITY() AS ErrorSeverity,
				ERROR_STATE() AS ErrorState,
				ERROR_PROCEDURE() AS ErrorProcedure,
				ERROR_LINE() AS ErrorLine,
				ERROR_MESSAGE() AS ErrorMessage		
	END CATCH
	
    FETCH NEXT FROM cursor_Setup INTO @dbName
END

CLOSE cursor_Setup
DEALLOCATE cursor_Setup


