/*
        @Mode parameter. 0=diagnose, 1=summarize, 2=index detail, 3=missing index detail, 4=diagnose detail
*/
EXEC dbo.sp_BlitzIndex @mode = 4
EXEC dbo.sp_BlitzIndex @DatabaseName='Windhaven', @SchemaName='dbo', @TableName='Payment';
EXEC dbo.sp_BlitzIndex @DatabaseName='Windhaven', @SchemaName='dbo', @TableName='Policy';


EXEC dbo.sp_BlitzFirst 
	@ExpertMode = 1, 
	@Seconds = 60

EXEC dbo.sp_BlitzWho 
	@ExpertMode =1

EXEC dbo.sp_Blitz 

EXEC dbo.sp_BlitzCache 
	@Top = 10, -- int
	@SortOrder = 'cpu'

EXEC dbo.sp_BlitzTrace 

EXEC dbo.SP_BlitzLock
	
SELECT TOP 100
	DEST.text AS Query,
	deqs.total_worker_time,
	deqs.execution_count 
FROM sys.dm_exec_query_stats AS DEQS
	CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS DEST
ORDER BY 2 DESC	

SELECT CAST(COUNT(DISTINCT plan_handle) AS NVARCHAR(50)) AS Details
FROM sys.dm_exec_query_stats qs
    CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
GROUP BY qs.query_hash,
         pa.value
HAVING COUNT(DISTINCT plan_handle) > 50
ORDER BY COUNT(DISTINCT plan_handle) DESC
OPTION (RECOMPILE);

SELECT 'EXEC dbo.sp_BlitzCache @OnlyQueryHashes = ''' + master.dbo.fn_varbintohexstr(qs.query_hash) + '''',
		COUNT(*)
FROM sys.dm_exec_query_stats qs
	CROSS APPLY sys.dm_exec_plan_attributes(qs.plan_handle) pa
WHERE pa.attribute = 'dbid'
GROUP BY qs.query_hash
ORDER BY 2 DESC;

EXEC dbo.sp_BlitzCache @OnlyQueryHashes = '0x6BC77EBD5C26753A';

SELECT sqltext.text, req.session_id, req.status, 
	req.command, req.cpu_time, req.total_elapsed_time
FROM sys.dm_exec_requests			  AS req
	CROSS APPLY sys.dm_exec_sql_text (sql_handle) AS sqltext;
	
GO

EXEC dbo.sp_HumanEvents
	@seconds_sample = 60,
	@event_type = 'waits'

EXEC dbo.sp_HumanEvents
	@seconds_sample = 60,
	@event_type = 'waits',
	@wait_duration_ms = 0,
	@gimme_danger = 1

EXEC dbo.sp_HumanEvents
	@seconds_sample = 60,
	@event_type = 'blocking'
	@database_name = ''

EXEC dbo.sp_HumanEvents
	@seconds_sample = 60,
	@event_type = 'compiles',
	@database_name = ''

EXEC dbo.sp_HumanEvents
	@seconds_sample = 60,
	@event_type = 'queries'
	@database_name = ''
	