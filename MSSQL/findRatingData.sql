IF OBJECT_ID('tempdb..#TableResult') IS NOT NULL DROP TABLE #TableResult;
CREATE TABLE #TableResult
( 
  rowID INT IDENTITY(1, 1), 
  tableName VARCHAR(200), 
  columnName VARCHAR(200), 
  totalRecords INT
);

SET NOCOUNT ON;

DECLARE 
    @SQL NVARCHAR(MAX),
    @SQLStatement NVARCHAR(MAX),
    @result INT,
    @tableNameVar VARCHAR(100),
    @columnNameVar VARCHAR(100),
	@ParmDefinition NVARCHAR(500),	
    @ratingVersionIDColumn VARCHAR(50) = 'ratingVersionID',
	@ratingVersionID VARCHAR(100) = '70';

SET @SQL = N'	
	DECLARE cur_TempCursor CURSOR FOR

	SELECT S.name + ''.'' + T.name AS tableName, C.name AS columnName
	FROM sys.tables AS T
		JOIN sys.columns AS C ON C.object_id = T.object_id
		JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	WHERE C.name LIKE ''%' + @ratingVersionIDColumn + '%''
	ORDER BY S.name, T.name	
';

EXEC sp_executesql @SQL

OPEN cur_TempCursor
FETCH NEXT FROM cur_TempCursor INTO @tableNameVar, @columnNameVar
	
WHILE @@FETCH_STATUS = 0
BEGIN		
	SET @ParmDefinition = N'@resultOUT INT OUTPUT';
    SET @SQLStatement = 'SELECT @resultOUT = (SELECT count(*) FROM ' + @tableNameVar + ' WHERE ' + @columnNameVar + ' = ' + @ratingVersionID + ')';
	EXEC sp_executesql @SQLStatement, @ParmDefinition, @result OUTPUT;

	IF @result > 0
	BEGIN		
		INSERT INTO #TableResult
		VALUES(@tableNameVar, @columnNameVar, @result) 
	END 

	FETCH NEXT FROM cur_TempCursor INTO @tableNameVar, @columnNameVar
END

CLOSE cur_TempCursor
DEALLOCATE cur_TempCursor
                   
SELECT *
FROM #TableResult