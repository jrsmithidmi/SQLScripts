SELECT [object_name], [counter_name], [cntr_value] AS seconds
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Manager%'
AND [counter_name] = 'Page life expectancy'