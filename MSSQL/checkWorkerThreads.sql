/*
Diagnostic Queries
*/

/* Overall workers */
SELECT s.cpu_id, w.scheduler_address, COUNT(*) AS workers 
FROM sys.dm_os_workers w
INNER JOIN sys.dm_os_schedulers s ON w.scheduler_address = s.scheduler_address
WHERE s.status = 'VISIBLE ONLINE'
GROUP BY s.cpu_id, w.scheduler_address
ORDER BY s.cpu_id, w.scheduler_address;

/* Running workers */
SELECT w.scheduler_address, w.worker_address, w.thread_address, w.state, w.last_wait_type
FROM sys.dm_os_workers w
INNER JOIN sys.dm_os_schedulers s ON w.scheduler_address = s.scheduler_address
WHERE s.status = 'VISIBLE ONLINE'
AND w.state = 'RUNNING'
ORDER BY w.scheduler_address

SELECT TOP 100
	DEST.text AS Query,
	deqs.total_worker_time,
	deqs.execution_count 
FROM sys.dm_exec_query_stats AS DEQS
	CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS DEST
ORDER BY 2 DESC
