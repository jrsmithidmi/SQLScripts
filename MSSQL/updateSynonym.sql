DECLARE @ObjectName sysname, @Definition VARCHAR(MAX), @Schema VARCHAR(50)
DECLARE @SQL VARCHAR(MAX)

DECLARE loccur CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY FOR
SELECT name, SCHEMA_NAME(schema_id), base_object_name FROM sys.synonyms
OPEN loccur

FETCH NEXT FROM loccur INTO @ObjectName, @Schema, @Definition

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT 'Converting: Synonym, ' + @ObjectName

    SET @SQL = 'DROP SYNONYM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@ObjectName)
    EXEC(@SQL)

    SET @SQL = 'CREATE SYNONYM ' + QUOTENAME(@Schema) + '.' + QUOTENAME(@ObjectName) + ' FOR ' +
                  REPLACE(@Definition, '[Evergreen', '[SaveMoney')
    EXEC(@SQL)

    FETCH NEXT FROM loccur INTO @ObjectName, @Schema, @Definition
END

CLOSE loccur
DEALLOCATE loccur