EXEC dbo.sp_WhoIsActive 
	@find_block_leaders = 1

/* More detail */
EXEC dbo.sp_WhoIsActive 
	@get_outer_command = 1, 
	@get_plans=1, 
	@get_locks=1, 
	@get_avg_time=1,
	@find_block_leaders = 1
	
-- Who is running what at this instant
SELECT dest.text AS 'Command text', der.total_elapsed_time AS 'total_elapsed_time (ms)',
		DB_NAME (der.database_id) AS 'DatabaseName', der.command, des.login_time, des.host_name, des.program_name,
		der.session_id
FROM			sys.dm_exec_requests				  AS der
	INNER JOIN	sys.dm_exec_connections				  AS dec ON der.session_id = dec.session_id
	INNER JOIN	sys.dm_exec_sessions				  AS des ON des.session_id = der.session_id
	CROSS APPLY sys.dm_exec_sql_text (der.sql_handle) AS dest
WHERE des.is_user_process = 1
	AND dest.text NOT LIKE '%-- Who is running what%'
ORDER BY [total_elapsed_time (ms)] DESC;