/*
60 (SQL Server 6.0)
65 (SQL Server 6.5)
70 (SQL Server 7.0)
80 (SQL Server 2000)
90 (SQL Server 2005)
100 (SQL Server 2008)
110 (SQL Server 2012)
120 (SQL Server 2014)
130 (SQL Server 2016)
140 (SQL Server 2017)
150 (SQL Server 2019)
*/

SELECT D.name, D.compatibility_level, 'ALTER DATABASE [' + D.name + '] SET COMPATIBILITY_LEVEL = 120' 
FROM sys.databases AS D
WHERE D.compatibility_level <> 120
