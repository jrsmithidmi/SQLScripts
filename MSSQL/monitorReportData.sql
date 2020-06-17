/* Blocking Reports */
IF (OBJECT_ID(N'tempdb..#FileList') IS NOT NULL) DROP TABLE #FileList ;
CREATE TABLE #FileList (
	fileListID INT NOT NULL IDENTITY(10,1),
	xfileName VARCHAR(100),
	depth INT,
	isFile TINYINT
);

IF OBJECT_ID('tempdb..#tmpBlocking') IS NOT NULL DROP TABLE #tmpBlocking
CREATE TABLE #tmpBlocking (
	tmpBlockingID INT NOT NULL IDENTITY(1,1),
	xmlData XML	
);

DECLARE 
	@SQLPath VARCHAR(100) = 'D:\SQLExtendedEvents\Blocking',
	@SQLStatement VARCHAR(500),
	@fileName VARCHAR(100);

INSERT INTO #FileList(xfileName, depth, isFile)
EXEC Master.dbo.xp_DirTree @SQLPath,1,1;	

DECLARE populateTempTable CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT xfileName 
FROM #FileList AS FL;

OPEN populateTempTable;

FETCH NEXT FROM populateTempTable INTO @fileName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLStatement = @SQLPath + '\' + @fileName;
	--PRINT @SQLStatement

	INSERT INTO #tmpBlocking (xmlData)
	SELECT CAST(event_data AS XML) AS event_data
	FROM sys.fn_xe_file_target_read_file(@SQLStatement, NULL, NULL, NULL);

    FETCH NEXT FROM populateTempTable INTO @fileName;
END

CLOSE populateTempTable;
DEALLOCATE populateTempTable;

/* Query temp table to return required data and parse xml */
DECLARE @today DATE = GETDATE()

SELECT TOP 50
	X.tmpBlockingID,
	X.blockedStartTime,
	X.blockedSQLText,
	X.blockedLoginname,
	X.blockedSPID,
	X.blockingBatchTime,
	X.blockingSPID,
	X.blockingHostname,
	X.blockingLoginname,
	X.blockingSQLText,
	X.blockedProcessReport
FROM (
SELECT 
	TB.tmpBlockingID, 
    CAST(TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@lasttranstarted)[1]', 'varchar(100)') AS DATETIME2(7)) AS blockedStartTime,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/inputbuf)[1]', 'varchar(max)') AS blockedSQLText, 
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@loginname)[1]', 'varchar(150)') AS blockedLoginname,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocked-process/process/@spid)[1]', 'varchar(50)') AS blockedSPID,
    CAST(TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@lastbatchstarted)[1]', 'varchar(100)') AS DATETIME2(7)) AS blockingBatchTime,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@spid)[1]', 'varchar(50)') AS blockingSPID,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@hostname)[1]', 'varchar(150)') AS blockingHostname,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/@loginname)[1]', 'varchar(150)') AS blockingLoginname,
    TB.xmlData.value('(event/data[@name="blocked_process"]/value/blocked-process-report/blocking-process/process/inputbuf)[1]', 'varchar(max)') AS blockingSQLText,
    TB.xmlData.query('(event/data[@name="blocked_process"]/value/blocked-process-report)[1]') as [blockedProcessReport]
FROM #tmpBlocking AS TB
) AS X
--WHERE CAST(X.blockedStartTime AS DATE) = @today
ORDER BY X.tmpBlockingID DESC


GO
/* Deadlock Reports */
IF (OBJECT_ID(N'tempdb..#FileList') IS NOT NULL) DROP TABLE #FileList ;
CREATE TABLE #FileList (
	fileListID INT NOT NULL IDENTITY(10,1),
	xfileName VARCHAR(100),
	depth INT,
	isFile TINYINT
);

IF OBJECT_ID('tempdb..#tmpDeadlock') IS NOT NULL DROP TABLE #tmpDeadlock
CREATE TABLE #tmpDeadlock (
	tmpDeadlockID INT NOT NULL IDENTITY(1,1),
	xmlData XML,
	createDateGMT DATETIME2(7),
	createDateLocal DATETIME2(7)
);

DECLARE 
	@SQLPath VARCHAR(100) = 'D:\SQLExtendedEvents\Deadlocks',
	@SQLStatement VARCHAR(500),
	@fileName VARCHAR(100);		

INSERT INTO #FileList(xfileName, depth, isFile)
EXEC Master.dbo.xp_DirTree @SQLPath,1,1;	

DECLARE populateTempTable CURSOR FAST_FORWARD READ_ONLY FOR 
SELECT xfileName 
FROM #FileList AS FL;

OPEN populateTempTable;

FETCH NEXT FROM populateTempTable INTO @fileName;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLStatement = @SQLPath + '\' + @fileName;
		
	INSERT INTO #tmpDeadlock ( xmlData, createDateGMT, createDateLocal )
	SELECT
			 Y.event_Data, 
			 CAST(Y.createDate AS DATETIME2(7)) AS 'createDateGMT',
			 CAST(DATEADD (hh, DATEDIFF (hh, GETUTCDATE (), GETDATE ()), Y.createDate) AS DATETIME2(7)) AS 'createDateLocal'
	FROM	 (
		SELECT X.event_Data, X.event_Data.value ('(/event/@timestamp)[1]', 'varchar(100)') AS 'createDate'
		FROM   (
			SELECT CAST(fn_xe_file_target_read_file.event_data AS XML) AS 'event_Data'
			FROM   sys.fn_xe_file_target_read_file (@SQLStatement, NULL, NULL, NULL)
		) AS X
	) AS Y

    FETCH NEXT FROM populateTempTable INTO @fileName;
END

CLOSE populateTempTable;
DEALLOCATE populateTempTable;

SELECT TOP 10 *
FROM #tmpDeadlock AS TD
ORDER BY TD.createDateLocal DESC