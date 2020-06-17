/* General database infomation */
SELECT	DB.database_id, CONVERT(VARCHAR(25), DB.name) AS dbName, CONVERT(VARCHAR(10), DATABASEPROPERTYEX(DB.name, 'status')) AS Status, DB.state_desc,
		(SELECT COUNT (1) FROM sys.master_files WHERE DB_NAME (database_id) = DB.name AND type_desc = 'rows') AS DataFiles, 
		(SELECT	SUM((size * 8) / 1024) FROM sys.master_files WHERE DB_NAME(database_id) = DB.name AND type_desc = 'rows') AS [Data MB], 
		(SELECT COUNT (1) FROM sys.master_files WHERE DB_NAME (database_id) = DB.name AND type_desc = 'log') AS LogFiles, 
		(SELECT	SUM((size * 8) / 1024) FROM	sys.master_files WHERE	DB_NAME(database_id) = DB.name AND type_desc = 'log') AS [Log MB], 
		DB.user_access_desc AS [User access], DB.recovery_model_desc AS [Recovery model],
		CASE DB.compatibility_level
			WHEN 60 THEN '60 (SQL Server 6.0)'
			WHEN 65 THEN '65 (SQL Server 6.5)'
			WHEN 70 THEN '70 (SQL Server 7.0)'
			WHEN 80 THEN '80 (SQL Server 2000)'
			WHEN 90 THEN '90 (SQL Server 2005)'
			WHEN 100 THEN '100 (SQL Server 2008)'
			WHEN 110 THEN '110 (SQL Server 2012)'
			WHEN 120 THEN '120 (SQL Server 2014)'
			WHEN 130 THEN '130 (SQL Server 2016)'
			WHEN 140 THEN '140 (SQL Server 2017)'
			WHEN 150 THEN '150 (SQL Server 2019)'
		END AS [compatibility level], CONVERT(VARCHAR(20), DB.create_date, 103) + ' ' + CONVERT(VARCHAR(20), DB.create_date, 108) AS [Creation date],
		ISNULL((SELECT TOP 1
						CASE BK.type
							WHEN 'D' THEN 'Full'
							WHEN 'I' THEN 'Differential'
							WHEN 'L' THEN 'Transaction log'
						END + ' – ' + LTRIM(ISNULL(STR(ABS(DATEDIFF(DAY, GETDATE(), BK.backup_finish_date))) + ' days ago', 'NEVER')) + ' – '
						+ CONVERT(VARCHAR(20), BK.backup_start_date, 103) + ' ' + CONVERT(VARCHAR(20), BK.backup_start_date, 108) + ' – '
						+ CONVERT(VARCHAR(20), BK.backup_finish_date, 103) + ' ' + CONVERT(VARCHAR(20), BK.backup_finish_date, 108) + ' ('
						+ CAST(DATEDIFF(SECOND, BK.backup_start_date, BK.backup_finish_date) AS VARCHAR(4)) + ' ' + 'seconds)'
				FROM	msdb..backupset BK
				WHERE	BK.database_name = DB.name
				ORDER BY BK.backup_set_id DESC
				), '-') AS [Last backup], 
		CASE 
			WHEN DB.is_fulltext_enabled = 1 THEN 'Fulltext enabled'
			ELSE ''
		END AS fulltext, 
		CASE	
			WHEN DB.is_auto_close_on = 1 THEN 'autoclose'
			ELSE ''
		END AS autoclose, 
		DB.page_verify_option_desc AS [page verify option],
		CASE
			WHEN DB.is_read_only = 1 THEN 'read only'
			ELSE ''
		END AS [read only], 
		CASE
			WHEN DB.is_auto_shrink_on = 1 THEN 'autoshrink'
			ELSE ''
		END AS autoshrink, 
		CASE
			WHEN DB.is_auto_create_stats_on = 1 THEN 'auto create statistics'
			ELSE ''
		END AS [auto create statistics], 
		CASE
			WHEN DB.is_auto_update_stats_on = 1 THEN 'auto update statistics'
			ELSE ''
		END AS [auto update statistics],
		CASE
			WHEN DB.is_in_standby = 1 THEN 'standby'
			ELSE ''
		END AS standby, 
		CASE	
			WHEN DB.is_cleanly_shutdown = 1 THEN 'cleanly shutdown'
			ELSE ''
		END AS [cleanly shutdown]
FROM	sys.databases DB
ORDER BY dbName, [Last backup] DESC, DB.name;

GO

/* Display size of DB and log DB */
SELECT	DB.database_id, CONVERT(VARCHAR(25), DB.name) AS dbName, 
		(SELECT	SUM((size * 8) / 1024)
		FROM	sys.master_files
		WHERE	DB_NAME(database_id) = DB.name
				AND type_desc = 'rows'
		) AS [Data MB], (SELECT	SUM((size * 8) / 1024)
						FROM sys.master_files
						WHERE DB_NAME(database_id) = DB.name
							AND type_desc = 'log'
						) AS [Log MB]
FROM	sys.databases DB
ORDER BY dbName;

GO

/* Display size of DB and log DB of more than 9GB */
WITH cteData AS ( 
	SELECT	DB.database_id, CONVERT(VARCHAR(25), DB.name) AS dbName, 
		CAST((SELECT	SUM((size * 8) / 1024)
				FROM	sys.master_files
				WHERE	DB_NAME(database_id) = DB.name
						AND type_desc = 'rows'
				) AS DECIMAL) / 1000 AS DataGB,
		CAST((SELECT	SUM((size * 8) / 1024)
				FROM	sys.master_files
				WHERE	DB_NAME(database_id) = DB.name
						AND type_desc = 'log'
				) AS DECIMAL) / 1000 AS LogGB
	FROM	sys.databases DB
)
SELECT	D.database_id, D.dbName, D.database_id, D.DataGB, D.database_id, D.LogGB
FROM	cteData AS D
WHERE	D.DataGB > 9;

GO

/* Identify objects that have QUOTED_IDENTIFIER OFF */
SELECT	M.uses_ansi_nulls, M.uses_quoted_identifier, O.name, O.type
FROM	sys.sql_modules AS M
JOIN	sys.objects AS O ON O.object_id = M.object_id
WHERE	M.uses_quoted_identifier = 0;

GO

SELECT
  CASE 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '8%' THEN 'SQL2000'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '9%' THEN 'SQL2005'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.0%' THEN 'SQL2008'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '10.5%' THEN 'SQL2008 R2'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '11%' THEN 'SQL2012'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '12%' THEN 'SQL2014'
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '13%' THEN 'SQL2016'     
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '14%' THEN 'SQL2017' 
     WHEN CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like '15%' THEN 'SQL2019' 
     ELSE 'unknown'
  END AS MajorVersion,
  SERVERPROPERTY('ProductLevel') AS ProductLevel,
  SERVERPROPERTY('Edition') AS Edition,
  SERVERPROPERTY('ProductVersion') AS ProductVersion

SELECT is_online, COUNT(*) AS CPUcores
FROM sys.dm_os_schedulers AS DOS
WHERE DOS.scheduler_id < 129
GROUP BY DOS.is_online

SELECT [value] memoryAssigned, [description] 
FROM sys.configurations
WHERE [name] = 'max server memory (MB)'
ORDER BY name OPTION (RECOMPILE);

DECLARE @productVersion VARCHAR(128) = CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')),
	@productVersionINT TINYINT,
	@sqlStatement VARCHAR(100);

SET @productVersionINT = SUBSTRING(@productVersion,1,CHARINDEX('.',@productVersion)-1);

IF @productVersionINT < 11
BEGIN
	-- Prior versions:
	SET @sqlStatement = 'SELECT physical_memory_in_bytes / 1024 AS totalServerMemory FROM sys.dm_os_sys_info;'
END
ELSE
BEGIN
	-- SQL Server 2012:
	SET @sqlStatement = 'SELECT physical_memory_kb / 1024 AS totalServerMemory FROM sys.dm_os_sys_info;'
END

EXEC (@sqlStatement)