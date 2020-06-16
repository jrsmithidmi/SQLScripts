CREATE TABLE #nightlyFileRead (	
	fromFile VARCHAR(MAX)
)

IF OBJECT_ID('tempdb..#nightlyFileRead') IS NOT NULL DROP TABLE #nightlyFileRead
BULK INSERT #nightlyFileRead
   FROM 'C:\NightlyLog\NightlyLog.txt'
   WITH 
      (
         ROWTERMINATOR ='\n'
      )

SELECT TOP 10000 *
FROM #nightlyFileRead AS NFR
ORDER BY 1 ASC

GO

DECLARE @SQLPath VARCHAR(100) = 'D:\SQL\';		
EXEC Master.dbo.xp_DirTree @SQLPath,1,1	