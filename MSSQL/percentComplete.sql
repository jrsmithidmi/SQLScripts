--Time based on sessionID
SELECT
	  dm_exec_requests.percent_complete						  AS '%Complete',
	  dm_exec_requests.estimated_completion_time / 60000	  AS 'TimeRemainingMin',
	  dm_exec_requests.estimated_completion_time * 0.00000024 AS 'TimeRemainingHours'
FROM  sys.dm_exec_requests
WHERE dm_exec_requests.session_id = 10;

--General time based on commands
SELECT
	dmv1.session_id	AS 'UserSessionID', dmv2.login_name AS 'SessionLoginName',
	dmv2.original_login_name AS 'ConnectionLoginName', dmv1.command AS 'TSQLCommandType', est.text AS 'TSQLCommandText',
	dmv2.status AS 'Status', dmv2.cpu_time AS 'CPUTime', dmv2.memory_usage AS 'MemoryUsage', dmv1.start_time AS 'StartTime',
	dmv1.percent_complete AS 'PercentComplete', dmv2.program_name AS 'ProgramName',
	CAST((( DATEDIFF (s, dmv1.start_time, CURRENT_TIMESTAMP)) / 3600 ) AS VARCHAR(32)) + ' hour(s), '
	+ CAST(( DATEDIFF (s, dmv1.start_time, CURRENT_TIMESTAMP) % 3600 ) / 60 AS VARCHAR(32)) + 'min, '
	+ CAST(( DATEDIFF (s, dmv1.start_time, CURRENT_TIMESTAMP) % 60 ) AS VARCHAR(32)) + ' sec' AS 'RunningTime',
	CAST(( dmv1.estimated_completion_time / 3600000 ) AS VARCHAR(32)) + ' hour(s), '
	+ CAST(( dmv1.estimated_completion_time % 3600000 ) / 60000 AS VARCHAR(32)) + 'min, '
	+ CAST(( dmv1.estimated_completion_time % 60000 ) / 1000 AS VARCHAR(32)) + ' sec' AS 'TimeRequiredToCompleteOperation',
	DATEADD (SECOND, dmv1.estimated_completion_time / 1000, CURRENT_TIMESTAMP) AS 'EstimatedCompletionTime'
FROM sys.dm_exec_requests AS dmv1
	CROSS APPLY sys.dm_exec_sql_text (sql_handle) AS est
	INNER JOIN	sys.dm_exec_sessions AS dmv2 ON dmv1.session_id = dmv2.session_id
WHERE dmv1.command IN (
	'ALTER INDEX REORGANIZE', 'AUTO_SHRINK', 'BACKUP DATABASE', 'DBCC CHECKDB', 'DBCC CHECKFILEGROUP',
	'DBCC CHECKTABLE', 'DBCC INDEXDEFRAG', 'DBCC SHRINKDATABASE', 'DBCC SHRINKFILE', 'RECOVERY', 'RESTORE DATABASE',
	'ROLLBACK', 'TDE ENCRYPTION', 'RESTORE LOG', 'BACKUP LOG', 'DbccFilesCompact', 'KILLED/ROLLBACK','DbccSpaceReclaim'
);

--Time to complete encryption
SELECT DB_NAME(database_id) AS DatabaseName, encryption_state,
	encryption_state_desc =
	CASE encryption_state
			 WHEN '0'  THEN  'No database encryption key present, no encryption'
			 WHEN '1'  THEN  'Unencrypted'
			 WHEN '2'  THEN  'Encryption in progress'
			 WHEN '3'  THEN  'Encrypted'
			 WHEN '4'  THEN  'Key change in progress'
			 WHEN '5'  THEN  'Decryption in progress'
			 WHEN '6'  THEN  'Protection change in progress (The certificate or asymmetric key that is encrypting the database encryption key is being changed.)'
			 ELSE 'No Status'
			 END,
	percent_complete,encryptor_thumbprint, encryptor_type  
FROM sys.dm_database_encryption_keys