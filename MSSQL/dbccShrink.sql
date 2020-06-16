EXECUTE master.sys.sp_MSforeachdb 'USE [?]; DBCC SHRINKFILE (2, 1)'
GO
