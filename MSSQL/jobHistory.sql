/* https://www.mssqltips.com/sqlservertip/2850/querying-sql-server-agent-job-history-data/ */

/* Display job history and step info */
SELECT
		 j.name AS "JobName", s.step_id AS "Step", s.step_name AS "StepName",
		 msdb.dbo.agent_datetime (h.run_date, h.run_time) AS "RunDateTime",
		 (( h.run_duration / 10000 * 3600 + ( h.run_duration / 100 ) % 100 * 60 + h.run_duration % 100 + 31 ) / 60 ) AS "RunDurationMinutes"
		 --, H.message --Uncomment to show job history
FROM	 msdb.dbo.sysjobs AS j
		 INNER JOIN msdb.dbo.sysjobsteps AS s
			 ON j.job_id = s.job_id
		 INNER JOIN msdb.dbo.sysjobhistory AS h
			 ON s.job_id = h.job_id AND s.step_id = h.step_id AND h.step_id <> 0
WHERE	 j.enabled = 1 --Only Enabled Jobs
		 AND msdb.dbo.agent_datetime (h.run_date, h.run_time) BETWEEN '7/07/2020' AND '7/8/2020' --Uncomment for date range queries
		 AND j.name <> 'DBA - Check TempDB Contention'
ORDER BY JobName, RunDateTime DESC;


/* Display job history count based on message text */
SELECT
		 X.name, COUNT (*)
FROM	 (
	SELECT
		  j.name, h.message
	FROM  msdb.dbo.sysjobs AS j
		  INNER JOIN msdb.dbo.sysjobhistory AS h
			  ON j.job_id = h.job_id
	WHERE j.enabled = 1 --Only Enabled Jobs
		  AND j.name <> 'DBA - Check TempDB Contention' --Uncomment to search for a single job
		  AND j.name <> 'DBA - Monitor Log Space'
		  AND j.name NOT IN (
				  N'syspolicy_purge_history', N'Nightlyprocess', N'DBA - Populate DBA Tables', N'DataOne_ETL',
				  N'DBA - AReport', N'Confie_CopyAggressiveBackups', N'DBA - Monitor Disk Space',
				  N'DBA - Get Blocking Details', N'DBA - Service Restart Check', N'SSIS Server Maintenance Job',
				  N'Login Script', N'DBA - IndexOptimize'
			  )
		  AND msdb.dbo.agent_datetime (h.run_date, h.run_time) BETWEEN '7/07/2020' AND '7/8/2020' --Uncomment for date range queries
) AS X
WHERE	 X.message LIKE '%access is denied%'
GROUP BY X.name;