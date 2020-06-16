SELECT sj.name AS "Job_Name", sl.name AS "Job_Owner"
FROM msdb.dbo.sysjobs_view AS sj
	LEFT JOIN master.sys.syslogins	AS sl ON sj.owner_sid = sl.sid
WHERE ( sl.denylogin = 1 AND sl.hasaccess = 0 )
	OR sl.sid IS NULL
ORDER BY sj.name;