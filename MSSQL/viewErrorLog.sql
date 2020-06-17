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

GO

CREATE TABLE #Errors (vchMessage varchar(2000), logDate smallDateTime, processInfo varchar(1000))

INSERT #Errors(logDate, processInfo, vchMessage) EXEC master.dbo.xp_readerrorlog

SELECT logDate, processInfo, RTRIM(LTRIM(vchMessage)) 
FROM #Errors 
WHERE
([vchMessage] like '%error%'
or [vchMessage] like '%fail%'
or [vchMessage] like '%Warning%'
or [vchMessage] like '%The SQL Server cannot obtain a LOCK resource at this time%'
or [vchMessage] like '%Autogrow of file%in database%cancelled or timed out after%'
or [vchMessage] like '%Consider using ALTER DATABASE to set smaller FILEGROWTH%'
or [vchMessage] like '% is full%'
or [vchMessage] like '% blocking processes%'
or [vchMessage] like '%SQL Server has encountered%IO requests taking longer%to complete%'
)
and [vchMessage] not like '%\ERRORLOG%'
and [vchMessage] not like '%Attempting to cycle errorlog%'
and [vchMessage] not like '%Errorlog has been reinitialized.%'
and [vchMessage] not like '%found 0 errors and repaired 0 errors.%'
and [vchMessage] not like '%without errors%'
and [vchMessage] not like '%This is an informational message%'
and [vchMessage] not like '%WARNING:%Failed to reserve contiguous memory%'
and [vchMessage] not like '%The error log has been reinitialized%'
and [vchMessage] not like '%Setting database option ANSI_WARNINGS%'
and [vchMessage] not like '%Error: 15457, Severity: 0, State: 1%'
and [vchMessage] <> 'Error: 18456, Severity: 14, State: 16.'

DROP TABLE #Errors