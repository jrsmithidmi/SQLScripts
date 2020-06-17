--Rset the identity
DBCC CHECKIDENT('dbo.RatingVersion', RESEED, 310);

--show statistics for a specific index
DBCC SHOW_STATISTICS("Policy",IX_Policy_Status_Includes);

--display open transactions
DBCC OPENTRAN(Aggressive);

--shrink all log files
EXECUTE master.sys.sp_MSforeachdb 'USE [?]; DBCC SHRINKFILE (2, 1)';






