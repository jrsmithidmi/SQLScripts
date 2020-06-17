USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_UnPivotSingleRow]    Script Date: 4/24/2019 11:50:12 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER OFF
GO



CREATE  PROCEDURE [dbo].[sp_UnPivotSingleRow]
	@database NVARCHAR(100),
	@schemaName NVARCHAR(100) = 'dbo',
	@tableName NVARCHAR(300),
	@keyValue INT = 0,
	@functionDef NVARCHAR(100) = '',
	@keyColumn	NVARCHAR(100) = ''
AS

/* Eliminates unwanted output from stored procedure; can help improve speed. */
SET NOCOUNT ON

	DECLARE 
	  @colNames		NVARCHAR(MAX) = N'',
	  @colValues	NVARCHAR(MAX) = N'',
	  @sql			NVARCHAR(MAX) = N'',
	  @ParmDef		NVARCHAR(500);
	
	IF @functionDef = ''
	BEGIN
		SET @sql = "
		SELECT @keyColumn_OUT = c.name
		FROM	" + @database + ".sys.indexes i
			INNER JOIN " + @database + ".sys.index_columns ic ON ic.object_id = i.object_id AND ic.index_id = i.index_id
			INNER JOIN " + @database + ".sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
			INNER JOIN " + @database + ".sys.tables T ON T.object_id = c.object_id
			INNER JOIN " + @database + ".sys.schemas AS S ON S.schema_id = T.schema_id 
			LEFT OUTER JOIN " + @database + ".sys.identity_columns idc ON idc.object_id = c.object_id	AND idc.column_id = c.column_id
		WHERE	i.is_primary_key = 1
		AND T.name = '" + @tableName + "'
		AND S.name = '" + @schemaName + "'";
		
		SET @ParmDef = N'@keyColumn_OUT NVARCHAR(100) OUTPUT';

		EXEC sys.sp_executesql @SQL, @ParmDef, @keyColumn_OUT = @keyColumn OUTPUT;

		SET @ParmDef = N'@colValues_OUT NVARCHAR(MAX) OUTPUT, @colNames_OUT NVARCHAR(MAX) OUTPUT';
		SET @SQL = "
			SELECT @colNames_OUT += ', ' + QUOTENAME(C.name), @colValues_OUT += ', ' + QUOTENAME(C.name) + ' = CONVERT(VARCHAR(320), ' + QUOTENAME(C.name) + ')'
			FROM " + @database + ".sys.columns c
				INNER JOIN " + @database + ".sys.tables T ON T.object_id = c.object_id
				INNER JOIN " + @database + ".sys.schemas AS S ON S.schema_id = T.schema_id 
			WHERE C.name <> '" + @keyColumn + "'
			AND T.name = '" + @tableName + "'
			AND S.name = '" + @schemaName + "' 
			ORDER BY C.name ";
	
		EXEC sys.sp_executesql @SQL, @ParmDef, @colValues_OUT = @colValues OUTPUT, @colNames_OUT = @colNames OUTPUT;
	
		SET @sql = N'SELECT ' + @keyColumn + ', Property, Value
		FROM
		(
		  SELECT ' + @keyColumn + @colValues + '
		   FROM ' + @database + '.' + @schemaName + '.' + @tableName + '
		   WHERE ' + @keyColumn + ' = ' + CAST(@keyValue AS VARCHAR(100)) + '
		) AS t
		UNPIVOT
		(
		  Value FOR Property IN (' + STUFF(@colNames, 1, 1, '') + ')
		) AS up;';


		SELECT @sql
	END
	ELSE
	BEGIN	
		SET @ParmDef = N'@colValues_OUT NVARCHAR(MAX) OUTPUT, @colNames_OUT NVARCHAR(MAX) OUTPUT';
		SET @SQL = "
			SELECT @colNames_OUT += ', ' + QUOTENAME(C.name), @colValues_OUT += ', ' + QUOTENAME(C.name) + ' = CONVERT(VARCHAR(320), ' + QUOTENAME(C.name) + ')'
			FROM sys.columns AS C
			WHERE object_id=object_id('" + @schemaName + "." + @tableName + "')
			AND C.name <> '" + @keyColumn + "'
			ORDER BY C.name ";
	
		EXEC sys.sp_executesql @SQL, @ParmDef, @colValues_OUT = @colValues OUTPUT, @colNames_OUT = @colNames OUTPUT;
		
		SET @sql = N'SELECT ' + @keyColumn + ', Property, Value
		FROM
		(
		  SELECT ' + @keyColumn + @colValues + '
		   FROM ' + @database + '.' + @schemaName + '.' + @tableName + @functionDef + '
		) AS t
		UNPIVOT
		(
		  Value FOR Property IN (' + STUFF(@colNames, 1, 1, '') + ')
		) AS up;';
	END

	CREATE TABLE #tmpPivot(
		id INT NOT NULL IDENTITY PRIMARY KEY CLUSTERED,
		keyColumn INT NOT NULL,
		property VARCHAR(200) NOT NULL,
		value VARCHAR(320) NOT NULL
	)
	
	INSERT INTO #tmpPivot (keyColumn, property, value)
	EXEC(@SQL);
	
	SET @keyValue = (SELECT TOP 1 keyColumn FROM #tmpPivot AS TP);

	SELECT keyColumn, property, value
	FROM #tmpPivot AS TP
	UNION
	SELECT @keyValue, @keyColumn, CAST(@keyValue AS VARCHAR(320))
	

GO

