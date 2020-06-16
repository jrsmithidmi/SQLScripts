
/*  check all tables in a DB for size */
SELECT 
	'SELECT TOP 10 * FROM ' + X.schemaName + '.' + X.tableName AS 'SELECT',
	'TRUNCATE TABLE ' + X.schemaName + '.' + X.tableName AS 'TRUNCATE',
	'DROP TABLE ' + X.schemaName + '.[' + X.tableName + ']' AS 'DROP',
	X.TableName, X.indexName, X.RowCounts, X.TotalPages, X.UsedPages, 
	X.DataPages, X.TotalSpaceMB, X.UsedSpaceMB, X.DataSpaceMB, 
	SUM(X.TotalSpaceMB) OVER() AS TotalMBUsed, 
	CAST(SUM(X.TotalSpaceMB) OVER() AS DECIMAL(19,5)) / 1024 AS TotalGBUsed
FROM (
SELECT	t.name AS TableName, i.name AS indexName, S.name AS schemaName, SUM(p.rows) AS RowCounts, SUM(a.total_pages) AS TotalPages, SUM(a.used_pages) AS UsedPages,
		SUM(a.data_pages) AS DataPages, (SUM(a.total_pages) * 8) / 1024 AS TotalSpaceMB, (SUM(a.used_pages) * 8) / 1024 AS UsedSpaceMB,
		(SUM(a.data_pages) * 8) / 1024 AS DataSpaceMB
FROM	sys.tables t
JOIN sys.schemas AS S ON S.schema_id =T.schema_id
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id
								AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
WHERE	t.name NOT LIKE 'dt%'
		AND i.object_id > 255
		AND i.index_id <= 1
		--AND T.name LIKE '%BAK%'
GROUP BY t.name, i.object_id, i.index_id, i.name, S.name
) AS X
ORDER BY X.RowCounts DESC;

GO

IF OBJECT_ID ('tempdb..#SpaceUsed') IS NOT NULL DROP TABLE #SpaceUsed;
IF OBJECT_ID ('tempdb..#SpaceUsedMB') IS NOT NULL DROP TABLE #SpaceUsedMB;

CREATE TABLE #SpaceUsed (
	TableName	  sysname,
	NumRows		  BIGINT,
	ReservedSpace VARCHAR(50),
	DataSpace	  VARCHAR(50),
	IndexSize	  VARCHAR(50),
	UnusedSpace	  VARCHAR(50)
);

DECLARE @str VARCHAR(500);

SET @str = 'exec sp_spaceused ''?''';

INSERT INTO #SpaceUsed EXEC sys.sp_MSforeachtable @command1 = @str;

SELECT S.TableName, S.NumRows, CONVERT (NUMERIC(18, 0), REPLACE (S.ReservedSpace, ' KB', '')) / 1024 AS 'ReservedSpace_MB',
		CONVERT (NUMERIC(18, 0), REPLACE (S.DataSpace, ' KB', '')) / 1024							   AS 'DataSpace_MB',
		CONVERT (NUMERIC(18, 0), REPLACE (S.IndexSize, ' KB', '')) / 1024							   AS 'IndexSpace_MB',
		CONVERT (NUMERIC(18, 0), REPLACE (S.UnusedSpace, ' KB', '')) / 1024						   AS 'UnusedSpace_MB'
INTO #SpaceUsedMB
FROM	 #SpaceUsed AS S

SELECT SU.TableName, SU.NumRows, SU.ReservedSpace_MB, SU.DataSpace_MB, SU.IndexSpace_MB, 
	SU.UnusedSpace_MB, SU.DataSpace_MB + SU.IndexSpace_MB AS totalTableSpace
FROM #SpaceUsedMB AS SU
UNION ALL
SELECT 'Total' AS tableName, SUM(SU.NumRows) AS numRows, SUM(SU.ReservedSpace_MB) AS reservedSpace, 
	SUM(SU.DataSpace_MB) AS dataSpace, SUM(SU.IndexSpace_MB) AS indexSpace, 
	SUM(SU.UnusedSpace_MB) AS unused, SUM(SU.DataSpace_MB) + SUM(SU.IndexSpace_MB)
FROM #SpaceUsedMB AS SU
ORDER BY SU.NumRows DESC