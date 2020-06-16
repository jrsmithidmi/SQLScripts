
-- Display last backup time 
SELECT	sdb.name AS DatabaseName, COALESCE(CONVERT(VARCHAR(12), MAX(bus.backup_finish_date), 101), '-') AS LastBackUpTime
FROM	sys.sysdatabases sdb
LEFT OUTER JOIN msdb.dbo.backupset bus ON bus.database_name = sdb.name
GROUP BY sdb.name;

GO

-- Get Backup History for required database
SELECT TOP 100
		s.database_name, m.physical_device_name, CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
		CAST(DATEDIFF(SECOND, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken, s.backup_start_date,
		CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn, CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn, CASE s.type
																										WHEN 'D' THEN 'Full'
																										WHEN 'I' THEN 'Differential'
																										WHEN 'L' THEN 'Transaction Log'
																									END AS BackupType, s.server_name, s.recovery_model
FROM	msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE	s.database_name = DB_NAME() -- Remove this line for all the database
ORDER BY s.backup_start_date DESC, s.backup_finish_date;
GO