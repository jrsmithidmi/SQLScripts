DECLARE @databaseName VARCHAR(100) = '' + '%'

IF OBJECT_ID('tempdb..#tmpWho2') IS NOT NULL DROP TABLE #tmpWho2
CREATE TABLE #tmpWho2(
        SPID INT,
        Status VARCHAR(200),
        LOGIN VARCHAR(200),
        HostName VARCHAR(200),
        BlkBy VARCHAR(100),
        DBName VARCHAR(200),
        Command VARCHAR(200),
        CPUTime INT,
        DiskIO INT,
        LastBatch VARCHAR(200),
        ProgramName VARCHAR(200),
        SPID_1 INT,
        REQUESTID INT
)

INSERT INTO #tmpWho2 EXEC sp_who2

SELECT  'KILL ' + CAST(T.SPID AS VARCHAR(100)),
		T.Status,
		T.LOGIN,
		T.HostName,
		T.BlkBy,
		T.DBName,
		T.Command,
		T.CPUTime,
		T.DiskIO,
		V.lastBatchDate,
		T.ProgramName,
		T.SPID_1,
		T.REQUESTID
FROM    #tmpWho2 AS T
	CROSS APPLY (VALUES(TRY_CAST(SUBSTRING(T.LastBatch, 1, CHARINDEX(' ', T.LastBatch, 1)-1) + '/' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)) + ' ' + SUBSTRING(T.LastBatch,  CHARINDEX(' ', T.LastBatch, 1)+ 1, LEN(T.LastBatch)) AS SMALLDATETIME))) AS V(lastBatchDate)
WHERE 1=1
AND T.LOGIN LIKE @databaseName
ORDER BY V.lastBatchDate

/* Specific User */
/*
SELECT  'KILL ' + CAST(T.SPID AS VARCHAR(100)),
		T.Status,
		T.LOGIN,
		T.HostName,
		T.BlkBy,
		T.DBName,
		T.Command,
		T.CPUTime,
		T.DiskIO,
		V.lastBatchDate,
		T.ProgramName,
		T.SPID_1,
		T.REQUESTID
FROM    #tmpWho2 AS T
	CROSS APPLY (VALUES(TRY_CAST(SUBSTRING(T.LastBatch, 1, CHARINDEX(' ', T.LastBatch, 1)-1) + '/' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)) + ' ' + SUBSTRING(T.LastBatch,  CHARINDEX(' ', T.LastBatch, 1)+ 1, LEN(T.LastBatch)) AS SMALLDATETIME))) AS V(lastBatchDate)
WHERE 1=1
AND T.LOGIN = ''
ORDER BY V.lastBatchDate
*/

SELECT T.LOGIN, COUNT(*) AS connectionCount
FROM    #tmpWho2 AS T
	CROSS APPLY (VALUES(TRY_CAST(SUBSTRING(T.LastBatch, 1, CHARINDEX(' ', T.LastBatch, 1)-1) + '/' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)) + ' ' + SUBSTRING(T.LastBatch,  CHARINDEX(' ', T.LastBatch, 1)+ 1, LEN(T.LastBatch)) AS SMALLDATETIME))) AS V(lastBatchDate)
WHERE 1=1
AND T.LOGIN LIKE @databaseName
GROUP BY T.LOGIN
ORDER BY connectionCount DESC

SELECT CAST(V.lastBatchDate AS DATE) AS LastUsedDate, COUNT(*) AS connectionCount
FROM    #tmpWho2 AS T
	CROSS APPLY (VALUES(TRY_CAST(SUBSTRING(T.LastBatch, 1, CHARINDEX(' ', T.LastBatch, 1)-1) + '/' + CAST(DATEPART(YEAR, GETDATE()) AS VARCHAR(4)) + ' ' + SUBSTRING(T.LastBatch,  CHARINDEX(' ', T.LastBatch, 1)+ 1, LEN(T.LastBatch)) AS SMALLDATETIME))) AS V(lastBatchDate)
WHERE 1=1
AND T.LOGIN LIKE @databaseName
GROUP BY CAST(V.lastBatchDate AS DATE)
ORDER BY LastUsedDate