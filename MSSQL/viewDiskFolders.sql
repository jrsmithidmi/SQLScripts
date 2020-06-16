DECLARE @SQL NVARCHAR(MAX),
	@fileName VARCHAR(100),
	@cur_TempCursor CURSOR,
	@SQLPath VARCHAR(100) = 'D:\';
	
IF OBJECT_ID('tempdb..#tmpFileList') IS NOT NULL DROP TABLE #tmpFileList
CREATE TABLE #tmpFileList(
	tmpFileListID INT NOT NULL IDENTITY,
	fileNames VARCHAR(100),
	depth TINYINT,
	isFile TINYINT
)

INSERT INTO #tmpFileList (fileNames, depth, isFile)
EXEC Master.dbo.xp_DirTree @SQLPath,1,1	
			
SELECT *
FROM #tmpFileList AS TFL