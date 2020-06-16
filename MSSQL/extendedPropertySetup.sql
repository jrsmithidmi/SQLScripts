EXEC sys.sp_addextendedproperty 
	@name='isExpense Value List', 
	@value='Values: 1 = something, 2 = nothing, 3 = new' , 
	@level0type='SCHEMA',
	@level0name='dbo', 
	@level1type='TABLE',
	@level1name='ClaimExpense', 
	@level2type='COLUMN',
	@level2name='isExpense'
GO
EXEC sys.sp_updateextendedproperty
	@name = 'isExpense Value List',
	@value='Values: 1 = something, 2 = nothing, 3 = new' , 
	@level0type='SCHEMA',
	@level0name='dbo', 
	@level1type='TABLE',
	@level1name='ClaimExpense', 
	@level2type='COLUMN',
	@level2name='isExpense'
GO
EXEC sys.sp_dropextendedproperty
	@name = 'isExpense Value List',
	@level0type='SCHEMA',
	@level0name='dbo', 
	@level1type='TABLE',
	@level1name='ClaimExpense', 
	@level2type='COLUMN',
	@level2name='isExpense'
GO
SELECT X.tableName, X.columnName, S2.Value 
FROM (
SELECT T.name AS tableName, C.name AS columnName, CAST(EP.value AS VARCHAR(2000)) AS [value]
FROM sys.tables AS T
	JOIN sys.columns AS C ON C.object_id = T.object_id
	JOIN sys.schemas AS S ON S.schema_id = T.schema_id
	JOIN sys.extended_properties AS EP ON EP.major_id = T.object_id AND EP.minor_id = C.column_id	
WHERE T.name = 'Policy'
AND S.name = 'dbo'
) AS X
CROSS APPLY dbo.Split(X.value,',') AS S2