
--THIS IS CRAZY IMPORTANT! IF YOU'RE USING Hoaic60, it needs to be there. Hoaic_Config, change it. Etc... etc...
--It's what ensures the script runs on the correct database!!!!
USE [Hoaic60]

--Script names should be in yyyy-mm-dd_SVDT-####_DESCRIPTION.sql format
--This allows things to be ran in order and easily identify what tickets they belong to
PRINT 'Executing YOUR_SCRIPT_NAME_HERE.sql'

BEGIN TRY
	BEGIN TRANSACTION [t1]
		/*****
			Common examples:
			Checking to see if a table/column exists
				NOTE: Using NOT here for adds. You would use IF EXISTS if you want to deletes/alters/etc...
				IF NOT EXISTS ( SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'columnToCheck' AND TABLE_NAME = 'tableToCheck' )
				IF NOT EXISTS ( SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tableToCheck' )

			Checking to see if a trigger exists
				IF EXISTS( SELECT * FROM sys.triggers WHERE object_id = OBJECT_ID( N'[dbo].[TRIGGERNAME]' ) ) 

			Checking to see if a function exists
				IF EXISTS( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID( N'[dbo].[FUNCTIONNAME]' ) AND TYPE IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ) )

			Checking to see if a stored proc exists:
				IF EXISTS( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID( N'[dbo].[PROCNAME]' ) AND type IN ( N'P', N'PC' ) ) 

			Checking to see if data exists:
				IF EXISTS( SELECT policyID FROM policy WHERE policyID = 1014 )

			Checking to see if foreign key exists:
				IF EXISTS( SELECT * FROM sys.objects WHERE object_id = OBJECT_ID( N'dbo.FK_TABLENAME_TABLENAME2' ) AND parent_object_id = OBJECT_ID( N'dbo.TableName' )
				
			NOTE ON stored procedures, functions, triggers, and keys: Usually easier to check for existance, drop them, and then do your add.

			UPDATE STATEMENTS FOR DATA DO NOT NEED AN EXISTANCE CHECK. They are already twice-run safe.


		*****/
		IF NOT EXISTS( #CRITERIA HERE# )
		BEGIN
			--Your action here
			
			PRINT 'Something that tells us what happened in the output'
		END
	COMMIT TRANSACTION [t1]

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION [t1]
	SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH

PRINT 'Script YOUR_SCRIPT_NAME_HERE.sql executed on ' ++ @@SERVERNAME + ' on ' + CAST( GETDATE() AS VARCHAR(50) )
