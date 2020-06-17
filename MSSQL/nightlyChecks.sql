SELECT *, DATEDIFF(MINUTE, SPL.startDate, SPL.endDate)
FROM dbo.SystemProcessLog AS SPL
WHERE SPL.startDate >= GETDATE() - 2
ORDER BY SPL.startDate

WITH cteNightly AS (
	SELECT TOP 10000 *, DATEDIFF(MINUTE, SPL.startDate, SPL.endDate) AS runTime
	FROM dbo.SystemProcessLog AS SPL
	WHERE SPL.startDate >= GETDATE() - 4
	ORDER BY SPL.startDate
)
SELECT *
FROM cteNightly AS X
WHERE X.runTime > 20

/* Run if you do not know the name of the files or you want to read another directory */
/*
DECLARE @SQLPath VARCHAR(100) = 'D:\NightlyLogs\';
EXEC Master.dbo.xp_DirTree @SQLPath,1,1	
*/
IF OBJECT_ID('tempdb..#tempData') IS NOT NULL DROP TABLE #tempData		
CREATE TABLE #tempData (
	FromFile VARCHAR(MAX)
);

/* Nightly filenames */ 
/*
Process1.txt
Process2.txt
*/

DECLARE
	@SQL NVARCHAR(MAX), 
	@fileName VARCHAR(100) = 'D:\NightlyLogs\Process1.txt' --change to the process that failed

SET @SQL = 'BULK INSERT #tempData FROM ''' + @fileName + '''';
EXEC(@SQL)

/* make sure to run as text output instead of grid  CTRL-T */
SELECT * 
FROM #tempData AS TD	


/* Processes to improve */

WITH cteNightly AS (
	SELECT *, DATEDIFF(MINUTE, SPL.startDate, SPL.endDate) AS runTime
	FROM dbo.SystemProcessLog AS SPL
	WHERE SPL.startDate >= GETDATE() - 30
)
SELECT X.processName, AVG(X.runTime) AS avgTime, MIN(X.runTime) AS minTime, MAX(X.runTime) AS maxTime, COUNT(*) AS runCount
FROM cteNightly AS X
WHERE X.runTime > 10
AND X.processName <> 'NightlyProcess'
GROUP BY X.processName
ORDER BY runCount DESC, avgTime DESC