SELECT [name] = OBJECT_NAME([object_id]), M.uses_ansi_nulls, M.uses_database_collation, 
	M.uses_quoted_identifier, M.is_schema_bound, M.is_recompiled, 
	M.null_on_null_input, M.execute_as_principal_id, M.[definition]
FROM sys.sql_modules AS M
WHERE M.uses_ansi_nulls = 0

SELECT TableName = QUOTENAME(SCHEMA_NAME(t.schema_id)) 
                + '.' 
                + QUOTENAME(t.name)
    , ColName = c.name
    , ColTypeName = ty.name
    , c.is_ansi_padded
    , ObjectType = t.[type]
    , ObjectTypeDesc = t.type_desc
FROM sys.columns c 
    INNER JOIN sys.objects t on t.object_id = c.object_id
    INNER JOIN sys.types ty 
        ON ty.system_type_id = c.system_type_id 
        AND ty.user_type_id = c.user_type_id
WHERE ty.name in ('char','varchar','binary','varbinary')
    --AND c.is_ansi_padded = 0 --you can filter on 0 to show the columns that are not following best practices.
ORDER BY 1,2