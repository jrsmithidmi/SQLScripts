/* Check to see if directory exists */
DECLARE @SQLPath VARCHAR(100) = 'D:\SQLExtendedEvents\';		
EXEC Master.dbo.xp_DirTree @SQLPath,1,1	

/* Create directory */
EXEC master.sys.xp_create_subdir 'D:\SQLExtendedEvents\Blocking\'

GO

/* Set blocking to log if 3 seconds or more */
EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'blocked process threshold', 3;
GO
RECONFIGURE;
GO
EXECUTE sp_configure 'show advanced options', 0;
GO
RECONFIGURE;

GO

/* Create block report with 5 files max 100MB each */
CREATE EVENT SESSION BlockedProcessReport
	ON SERVER
	ADD EVENT sqlserver.blocked_process_report
	ADD TARGET package0.event_file
	( SET filename = N'D:\SQLExtendedEvents\Blocking\BlockedProcessReport.xel', max_file_size=(100), max_rollover_files=(5) )
	WITH (
		MAX_MEMORY = 8192KB,
		EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
		MAX_DISPATCH_LATENCY = 30 SECONDS,
		MAX_EVENT_SIZE = 0KB,
		MEMORY_PARTITION_MODE = NONE,
		TRACK_CAUSALITY = OFF,
		STARTUP_STATE = ON
	);
GO

/* Start capture */
ALTER EVENT SESSION BlockedProcessReport 
ON SERVER STATE = START;
GO

/* Create directory */
EXEC master.sys.xp_create_subdir 'D:\SQLExtendedEvents\Deadlocks\'

/* Create deadlock report with 10 files max 1GB each */
CREATE EVENT SESSION [Deadlock_Monitor] ON SERVER 
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file(SET filename=N'D:\SQLExtendedEvents\Deadlocks\DeadLock.xel',max_file_size=(1000),max_rollover_files=(10))
WITH (MAX_MEMORY=4096 KB,EVENT_RETENTION_MODE=ALLOW_SINGLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=ON);
GO

/* Start capture */
ALTER EVENT SESSION [Deadlock_Monitor] 
ON SERVER STATE = START;
GO