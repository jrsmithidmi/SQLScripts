/* Reads VS Writes */
SELECT DB.name, O.name AS table_Name, 
	(US.user_seeks + US.user_scans + US.user_lookups) AS reads,
	US.user_updates AS writes, IX.name AS index_Name
FROM sys.dm_db_index_usage_stats AS US
	JOIN sys.databases AS DB ON DB.database_id = US.database_id
	JOIN sys.objects AS O ON O.object_id = US.object_id
	JOIN sys.indexes AS IX ON IX.object_id = US.object_id AND US.index_id = IX.index_id
ORDER BY DB.name, O.name, IX.name;

/* Reads VS Writes Percent */	
WITH reads_and_writes AS (
SELECT DB.name, 
	SUM(US.user_seeks + US.user_scans + US.user_lookups) AS reads,
	SUM(US.user_updates) AS writes,
	SUM(US.user_seeks + US.user_scans + US.user_lookups + US.user_updates) AS all_activity
FROM sys.dm_db_index_usage_stats AS US
	JOIN sys.databases AS DB ON DB.database_id = US.database_id
GROUP BY DB.name
)
SELECT RW.name, RW.reads, RW.writes, RW.all_activity, 
	((RW.reads * 1.0) / RW.all_activity) * 100 AS reads_percent, 
	((RW.writes * 1.0) / RW.all_activity) * 100 AS writes_percent
FROM reads_and_writes AS RW
ORDER BY RW.name;