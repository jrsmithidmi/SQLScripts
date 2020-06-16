IF OBJECT_ID('tempdb..#tmpErrorLog') IS NOT NULL DROP TABLE #tmpErrorLog
CREATE TABLE #tmpErrorLog (
	errorLogID INT NOT NULL IDENTITY(10,1),
	logDate DATETIME2(7),
	processInfo VARCHAR(100),
	errorMessage NVARCHAR(MAX)
)

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 0, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 1, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 2, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 3, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 4, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 5, 1, NULL, NULL, NULL, NULL, N'desc'

INSERT INTO #tmpErrorLog
EXEC master.dbo.xp_readerrorlog 6, 1, NULL, NULL, NULL, NULL, N'desc'


SELECT CAST(E.logDate AS DATE), COUNT(*)
FROM #tmpErrorLog AS E
WHERE E.errorMessage LIKE '%I/O device error%'
GROUP BY CAST(E.logDate AS DATE)
ORDER BY 1 DESC

SELECT *
FROM #tmpErrorLog AS E
WHERE  CAST(E.logDate AS DATE) = '2018-12-01'
ORDER BY E.logDate