USE master;
GO
/*
USE WindhavenFLImport
GO
SELECT
	 database_files.file_id, database_files.name AS 'logical_file_name', database_files.physical_name
FROM sys.database_files;
*/
GO
--Disconnect all existing session.
ALTER DATABASE WindhavenFLImport SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
--Change database in to OFFLINE mode.
ALTER DATABASE WindhavenFLImport SET OFFLINE;
GO

ALTER DATABASE WindhavenFLImport
	MODIFY FILE (
		NAME = 'svexport', FILENAME = 'D:\SQLData\WindhavenFLImport_JRS.mdf'
	);
GO
ALTER DATABASE WindhavenFLImport
	MODIFY FILE (
		NAME = 'svexport_log', FILENAME = 'D:\SQLData\WindhavenFLImport_log_JRS.ldf'
	);
GO
ALTER DATABASE WindhavenFLImport
	MODIFY FILE (
		NAME = 'svexport2', FILENAME = 'D:\SQLData\WindhavenFLImport2_JRS.ndf'
	);
GO
ALTER DATABASE WindhavenFLImport
	MODIFY FILE (
		NAME = 'svexport_log2', FILENAME = 'D:\SQLData\WindhavenFLImport_log2_JRS.ldf'
	);
GO

GO
ALTER DATABASE WindhavenFLImport SET ONLINE;
GO

USE master;
GO
ALTER DATABASE WindhavenFLImport SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
EXEC master..sp_renamedb 'WindhavenFLImport', 'WindhavenFLImport_JRS';
GO
ALTER DATABASE WindhavenFLImport_JRS SET MULTI_USER;
GO
