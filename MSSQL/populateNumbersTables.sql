IF OBJECT_ID('utils.Number') IS NOT NULL DROP TABLE utils.Number;
DROP TABLE utils.Number
DECLARE @RunDate datetime
SET @RunDate=GETDATE()
SELECT TOP 100000000 IDENTITY(int,1,1) AS Num
    INTO utils.Number
    FROM sys.objects s1       --use sys.columns if you don't get enough rows returned to generate all the numbers you need
		CROSS JOIN sys.objects s2 --use sys.columns if you don't get enough rows returned to generate all the numbers you need
		CROSS JOIN sys.objects s3 --use sys.columns if you don't get enough rows returned to generate all the numbers you need
		CROSS JOIN sys.objects s4 --use sys.columns if you don't get enough rows returned to generate all the numbers you need
		CROSS JOIN sys.objects s5 --use sys.columns if you don't get enough rows returned to generate all the numbers you need
ALTER TABLE utils.Number ADD CONSTRAINT PK_Number PRIMARY KEY CLUSTERED (Num)
PRINT CONVERT(varchar(20),datediff(ms,@RunDate,GETDATE()))+' milliseconds'
SELECT COUNT(*) FROM utils.Number

/*
	http://stackoverflow.com/questions/1393951/what-is-the-best-way-to-create-and-populate-a-numbers-table
*/