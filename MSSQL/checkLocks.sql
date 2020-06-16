IF OBJECT_ID('tempdb..#holding_locks') IS NOT NULL DROP TABLE #holding_locks;
SELECT	 COUNT (1) AS 'lock_count', dm_tran_locks.request_session_id
INTO	 #holding_locks
FROM	 sys.dm_tran_locks
GROUP BY dm_tran_locks.request_session_id
ORDER BY 1 DESC;

--sessions holding locks
SELECT
			   hl.lock_count, hl.request_session_id, s.login_name, s.program_name, s.host_name
FROM		   #holding_locks		AS hl
	INNER JOIN sys.dm_exec_sessions AS s ON hl.request_session_id = s.session_id;

--active sessions
SELECT
				hl.request_session_id, hl.lock_count,
				SUBSTRING (st.text, ( er.statement_start_offset / 2 ) + 1, (( CASE er.statement_end_offset
																				  WHEN -1 THEN DATALENGTH (st.text)
																				  ELSE er.statement_end_offset
																			  END - er.statement_start_offset
																			) / 2
																		   ) + 1
				) AS 'statement_text', CONVERT (XML, qp.query_plan)
FROM			#holding_locks						 AS hl
	INNER JOIN	sys.dm_exec_requests				 AS er ON er.session_id = hl.request_session_id
	CROSS APPLY sys.dm_exec_sql_text (er.sql_handle) AS st
	CROSS APPLY sys.dm_exec_text_query_plan (er.plan_handle, er.statement_start_offset, er.statement_end_offset) AS qp
ORDER BY		hl.lock_count DESC;

--idle sessions
SELECT
				hl.request_session_id, hl.lock_count,
				SUBSTRING (st.text, ( qs.statement_start_offset / 2 ) + 1, (( CASE qs.statement_end_offset
																				  WHEN -1 THEN DATALENGTH (st.text)
																				  ELSE qs.statement_end_offset
																			  END - qs.statement_start_offset
																			) / 2
																		   ) + 1
				) AS 'statement_text', CONVERT (XML, qp.query_plan)
FROM			#holding_locks						 AS hl
	INNER JOIN	sys.dm_exec_connections				 AS c ON hl.request_session_id = c.session_id
	INNER JOIN	sys.dm_exec_query_stats				 AS qs ON qs.sql_handle = c.most_recent_sql_handle
	CROSS APPLY sys.dm_exec_sql_text (qs.sql_handle) AS st
	CROSS APPLY sys.dm_exec_text_query_plan (qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) AS qp
WHERE			NOT EXISTS (
	SELECT 1 FROM sys.dm_exec_requests AS er WHERE er.session_id = hl.request_session_id
)
ORDER BY		hl.lock_count DESC, qs.statement_start_offset;


--SQL Server 2012 or later
SELECT SUM(pages_kb)/128 AS lock_memory_megabytes, type FROM sys.dm_os_memory_clerks GROUP BY type ORDER BY 1 DESC

--SQL Server 2008
--SELECT (SUM(single_pages_kb) + SUM(multi_pages_kb))/128 AS lock_memory_megabytes, type FROM sys.dm_os_memory_clerks GROUP BY type ORDER BY 1 DESC

/*

-- get detail listing
SELECT Operation, [Transaction ID], Context, AllocUnitName, Description
FROM sys.fn_dblog(NULL,NULL)
WHERE AllocUnitName LIKE 'credit.CreditScore%' 

-- group by each operation
SELECT Operation, AllocUnitName, Context, count(*)
FROM sys.fn_dblog(NULL,NULL)
WHERE AllocUnitName LIKE 'credit.CreditScore%'
GROUP BY Operation, AllocUnitName, Context


*/