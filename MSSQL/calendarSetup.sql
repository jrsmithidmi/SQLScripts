IF NOT EXISTS(SELECT * FROM sys.schemas AS S WHERE S.name = 'utils')
BEGIN
	EXEC ('CREATE SCHEMA [utils] AUTHORIZATION [dbo]');
END
GO
	GRANT EXECUTE, SELECT, UPDATE, DELETE, INSERT ON SCHEMA::utils TO PTS_User
GO
IF EXISTS(SELECT * FROM sys.objects AS O WHERE O.[type] IN ('FN', 'IF', 'TF') AND O.name = 'GetEasterHolidays')
BEGIN
	DROP FUNCTION utils.GetEasterHolidays
END
GO
CREATE FUNCTION [utils].[GetEasterHolidays](@year INT) 
RETURNS TABLE
WITH SCHEMABINDING
AS 
RETURN 
(
  WITH x AS 
  (
    SELECT [Date] = CONVERT(DATE, RTRIM(@year) + '0' + RTRIM([Month]) 
        + RIGHT('0' + RTRIM([Day]),2))
      FROM (SELECT [Month], [Day] = DaysToSunday + 28 - (31 * ([Month] / 4))
      FROM (SELECT [Month] = 3 + (DaysToSunday + 40) / 44, DaysToSunday
      FROM (SELECT DaysToSunday = paschal - ((@year + @year / 4 + paschal - 13) % 7)
      FROM (SELECT paschal = epact - (epact / 28)
      FROM (SELECT epact = (24 + 19 * (@year % 19)) % 30) 
        AS epact) AS paschal) AS dts) AS m) AS d
  )
  SELECT [Date], HolidayName = 'Easter Sunday' FROM x
    UNION ALL SELECT DATEADD(DAY,-2,[Date]), 'Good Friday'   FROM x
    UNION ALL SELECT DATEADD(DAY, 1,[Date]), 'Easter Monday' FROM x
);
GO
IF EXISTS(SELECT * FROM sys.procedures AS P WHERE P.[name] = 'CalendarSetup')
BEGIN
	DROP PROCEDURE utils.CalendarSetup
END
GO
CREATE PROCEDURE [utils].[CalendarSetup]
	@startDate Date = '1/1/1900',
	@endDate Date = '12/31/2100'
	
AS
BEGIN	
	SET NOCOUNT ON;

	/*

	-- =============================================
	-- Author:		Jamie Smith
	-- Create date:	2/5/2019
	-- Description:	Creates the tools.dateDim table
	-- =============================================

	Column Descriptions

	DateId               
		Unique ID = Days since 1753-01-01

	EndOfDay  

	Date                            
		Date at Midnight(00:00:00.000)

	NextDayDate                   
		Next day after DATE at Midnight(00:00:00.000)
		Intended to be used in queries against columns
		containing datetime values (1998-12-13 14:35:16)
		that need to join to a DATE.
		Example:

		from
			MyTable a
			join
			DATE b
			on	a.DateTimeCol >= b. DATE	and
				a.DateTimeCol < b.NextDayDate

	CalendarYear                           
		Year number in format YYYY, Example = 2005

	CalendarYearQuarter                    
		Year and Quarter number in format YYYYQ, Example = 20052

	CalendarYearMonth             
		Year and Month number in format YYYYMM, Example = 200511

	CalendarYearDayOfYear              
		Year and Day of Year number in format YYYYDDD, Example = 2005364

	CalendarQuarter                         
		Quarter number in format Q, Example = 4

	CalendarMonth                 
		Month number in format MM, Example = 11

	CalendarWeek
		week of year

	CalendarDayOfYear                     
		Day of Year number in format DDD, Example = 362

	CalendarDayofMonth
		Day of Month number in format DD, Example = 31

	CalendarDayOfWeek                    
		Day of week number, Sun=1, Mon=2, Tue=3, Wed=4, Thu=5, Fri=6, Sat=7

	CalendarYearName
		Year name text in format YYYY, Example = 2005

	CalendarYearQuarterName
		Year Quarter name text in format YYYY QQ, Example = 2005 Q3

	CalendarYearMonthName
		Year Month name text in format YYYY MMM, Example = 2005 Mar

	CalendarYearMonthNameLong
		Year Month long name text in format YYYY MMMMMMMMM,
		Example = 2005 September

	CalendarQuarterName
		Quarter name text in format QQ, Example = Q1

	CalendarMonthName
		Month name text in format MMM, Example = Mar

	CalendarMonthNameLong
		Month long name text in format MMMMMMMMM, Example = September

	WeekdayName                    
		Weekday name text in format DDD, Example = Tue

	WeekdayNameLong               
		Weekday long name text in format DDDDDDDDD, Example = Wednesday

	CalendarStartOfYearDate
		First Day of Year that DATE is in

	CalendarEndOfYearDate
		Last Day of Year that DATE is in

	CalendarStartOfQuarterDate
		First Day of Quarter that DATE is in

	CalendarEndOfQuarterDate
		Last Day of Quarter that DATE is in

	CalendarStartOfMonthDate
		First Day of Month that DATE is in

	CalendarEndOfMonthDate
		Last Day of Month that DATE is in
 
	QuarterSeqNo                  
		Sequential Quarter number as offset from Quarter starting 1753/01/01

	MonthSeqNo                    
		Sequential Month number as offset from Month starting 1753/01/01

	WeekSeqNo                    
		Sequential Week number as offset from Week starting 1753/01/01
 
	FiscalYearPeriod
	 Fiscal Year number and Period numberd. YYYY.PP, Example = 2000.01
 
	FiscalYearName
	 Fiscal Year Number. YYYY, Example = 2000
 
	FiscalYearDayOfYear
	 Fiscal Year and Day of Year number in format YYYY.DDD, Example = 2000.001
 
	FiscalYearWeekName
	 Fiscal Year, Period, and Day in format YYYY.PP.WW, Example 2000.01.1

	FiscalSemester
	 Fiscal Semester Number, Example = 1
 
	FiscalQuarter
	 Fiscal Quarter Number, Example = 3

	FiscalPeriod
	 Fiscal Period Number, Example = 10

	FiscalDayOfYear
	 Fiscal Day of Year Number ddd, Example = 340

	FiscalDayOfPeriod
	 Fiscal Day of Period Number dd, Example = 15

	FiscalWeekName
	 Fiscal Period Number and Week Number mm.y, Example = 12.1

	FiscalStartOfYearDate
	 First Day of Fiscal Year that DATE is in. Defaults to Jan 1. 
 
	FiscalEndOfYearDate
	 Last Day of Fiscal Year that DATE is in. Defaults to Dec 31. 
 
	FiscalStartOfPeriodDate
	 First Day of Fiscal Period that DATE is in. Defaults to 1st of month. 

	FiscalEndOfPeriodDate
	 Last Day of Fiscal Period that DATE is in. Defaults to last day of month. 
 
	ISODate                        
		ISO 8601 Date in format YYYY-MM-DD, Example = 2004-02-29

	ISOYearWeekNo                
		ISO 8601 year and week in format YYYYWW, Example = 200403

	ISOWeekNo                     
		ISO 8601 week of year in format WW, Example = 52

	ISODayOfWeek                 
		ISO 8601 Day of week number, 
		Mon=1, Tue=2, Wed=3, Thu=4, Fri=5, Sat=6, Sun=7

	ISOYearWeekName              
		ISO 8601 year and week in format YYYY-WNN, Example = 2004-W52

	ISOYearWeekDayOfWeekName  
		ISO 8601 year, week, and day of week in format YYYY-WNN-D,
		Example = 2004-W52-2

	DateFormatYYYYMMDD          
		Text date in format YYYY/MM/DD, Example = 2004/02/29

	DateFormatYYYYMD            
		Text date in format YYYY/M/D, Example = 2004/2/9

	DateFormatMMDDYEAR          
		Text date in format MM/DD/YYYY, Example = 06/05/2004

	DateFormatMDYEAR            
		Text date in format M/D/YYYY, Example = 6/5/2004

	DateFormatMMMDYYYY          
		Text date in format MMM D, YYYY, Example = Jan 4, 2006

	DateFormatMMMMMMMMMDYYYY    
		Text date in format MMMMMMMMM D, YYYY, Example = September 3, 2004

	DateFormatMMDDYY            
		Text date in format MM/DD/YY, Example = 06/05/97

	DateFormatMDYY              
		Text date in format M/D/YY, Example = 6/5/97
	
	WorkDay	
		= "Work Day" if is work day else says "No Work" if not
		Work Day defaults to M-F work week. 
 
	IsWorkDay = 1 if day is work day and 0 if not. Defaults to M-F work week.

	*/


	   CREATE TABLE #DATE 
	   (
	   [DateId]				[int]		not null, 
	   DateValue							Date	not null primary key clustered,
	   [NextDayDate]					Date	not null,
	   [CalendarYear]					[smallint]	not null,
	   [CalendarYearQuarter]			[int]	not null,
	   [CalendarYearMonth]				[int]		not null,
	   [CalendarYearDayOfYear]			[int]		not null,
	   [CalendarQuarter]				[tinyint]	not null,
	   [CalendarMonth]					[tinyint]	not null,
	   [CalendarWeek]					[tinyint]	not null,
	   [CalendarDayOfYear]				[smallint]	not null,
	   [CalendarDayOfMonth]			[smallint]	not null,
	   [CalendarDayOfWeek]				[tinyint]	not null,
	   [CalendarYearName]				[varchar] (4)	not null,
	   [CalendarYearQuarterName]		[varchar] (7)	not null,
	   [CalendarYearMonthName]			[varchar] (8)	not null,
	   [CalendarYearMonthNameLong]		[varchar] (14)	not null,
	   [CalendarQuarterName]			[varchar] (2)	not null,
	   [CalendarMonthName]				[varchar] (3)	not null,
	   [CalendarMonthNameLong]			[varchar] (9)	not null,
	   [WeekdayName]					[varchar] (3)	not null,
	   [WeekdayNameLong]				[varchar] (9)	not null,
	   [CalendarStartOfYearDate]		Date	not null,
	   [CalendarEndOfYearDate]			Date	not null,
	   [CalendarStartOfQuarterDate]	Date	not null,
	   [CalendarEndOfQuarterDate]		Date	not null,
	   [CalendarStartOfMonthDate]		Date	not null,
	   [CalendarEndOfMonthDate]		Date	not null,
	   [QuarterSeqNo]					[int]		not null,
	   [MonthSeqNo]					[int]	not	 null,
	   [WeekSeqNo]					[int]	not	 null,
	   [FiscalYearName]				[smallint] 	not null,
	   [FiscalYearPeriod]				[numeric] (6,2)		not null,
	   [FiscalYearDayOfYear]			[numeric] (7,3) 		not null,
	   --[FiscalYearWeekName] 			Char(9) not null,
	   [FiscalSemester]				[tinyint]  not null,
	   [FiscalQuarter]					[tinyint]  not null,
	   [FiscalPeriod]					[tinyint]	not null,
	   [FiscalDayOfYear]				[smallint]	not null,
	   [FiscalDayOfPeriod]				[tinyint]	not null,
	   --[FiscalWeekName]         		[numeric](3,1)  not null,
	   [FiscalStartOfYearDate]			Date	not null,
	   [FiscalEndOfYearDate]			Date	not null,
	   [FiscalStartOfPeriodDate]		Date	not null,
	   [FiscalEndOfPeriodDate]			Date	not null,
	   [ISODate]						[char](10)		not null,
	   [ISOYearWeekNo]					[int]			not null,
	   [ISOWeekNo]						[smallint]		not null,
	   [ISODayOfWeek]					[tinyint]		not null,
	   [ISOYearWeekName]				[varchar](8)	not null,
	   [ISOYearWeekDayOfWeekName]		[varchar](10)	not null,
	   [DateFormatYYYYMMDD]			[char](10)		not null,
	   [DateFormatYYYYMD]				[varchar](10)	not null,
	   [DateFormatMMDDYEAR]			[char](10)		not null,
	   [DateFormatMDYEAR]				[varchar](10)	not null,
	   [DateFormatMMMDYYYY]			[varchar](12)	not null,
	   [DateFormatMMMMMMMMMDYYYY]		[varchar](18)	not null,
	   [DateFormatMMDDYY]				[char](8)		not null,
	   [DateFormatMDYY]				[varchar](8)	not null,
	   [WorkDay]						[varchar](8)	not null,
	   [IsWorkDay]						[bit]			not null,
	   [weekendFlag]					[bit]			not null,
	   [relativeDayCount]				[int]			not null,
	   [relativeWeekCount]				[int]			not null,
	   [relativeMonthCount]			[int]			not null,
	   [isLastDayOfMonth]			  	[tinyint] NOT NULL DEFAULT ((0)),
	   [knightbrookeFiscalYear] INT NOT NULL,
	   [exportLastDayofNextMonth] [varchar](8) not null,
	   [DateExportYYYYMMDD] char(8) not NULL,
	   [daysInMonth] TINYINT NOT NULL,
	   [IsUSHoliday] BIT NOT NULL,
	   [HolidayText] VARCHAR(64) NULL,
		FirstOfMonth DATE  NULL,
		FirstOfYear DATE  NULL,
		FirstDayOfMonth     DATE         NULL,
		LastDayOfMonth      DATE         NULL,
		FirstDayOfQuarter   DATE         NULL,
		LastDayOfQuarter    DATE         NULL,
		FirstDayOfYear      DATE         NULL,
		LastDayOfYear       DATE         NULL,
		FirstDayOfNextMonth DATE         NULL,
		FirstDayOfNextYear  DATE         NULL,
		DOWInMonth TINYINT NULL
	   ) 


	   declare @cr			varchar(2)
	   select @cr			= char(13)+Char(10)
	   declare @ErrorMessage		varchar(400)
	   declare @START_DATE		datetime
	   declare @END_DATE		datetime
	   declare @LOW_DATE	datetime

	   declare	@start_no	int
	   declare	@end_no	int

	   -- Verify @startDate is not null 
	   if @startDate is null
		   BEGIN
			  SELECT '@startDate cannot be null'
			  RETURN
		   END

	   -- Verify @endDate is not null 
	   if @endDate is null
		   BEGIN
			  SELECT '@endDate cannot be null'
			  RETURN
		   END

	   -- Verify @startDate is not before 1754-01-01
	   IF  @startDate < '17540101'	
		  BEGIN
			 SELECT '@startDate cannot before 1754-01-01' + ', @startDate = '+ isnull(convert(varchar(40),@startDate,121),'NULL')
			 RETURN
		  END

	   -- Verify @endDate is not after 9997-12-31
	   IF  @endDate > '99971231'	
		  BEGIN
			 SELECT '@endDate cannot be after 9997-12-31'+', @endDate = '+isnull(convert(varchar(40),@endDate,121),'NULL')
			 RETURN
		  END 

	   -- Verify @startDate is not after @endDate
	   if @startDate > @endDate
		   BEGIN
			  SELECT '@startDate cannot be after @endDate' + ', @startDate = '+isnull(convert(varchar(40),@startDate,121),'NULL') + ', @endDate = ' 
			  + isnull(convert(varchar(40),@endDate,121),'NULL')
			 RETURN
		   END

	   -- Set @START_DATE = @startDate at midnight
	   select @START_DATE	= dateadd(dd,datediff(dd,0,@startDate),0)
	   -- Set @END_DATE = @endDate at midnight
	   select @END_DATE	= dateadd(dd,datediff(dd,0,@endDate),0)
	   -- Set @LOW_DATE = earliest possible SQL Server datetime
	   select @LOW_DATE	= convert(datetime,'17530101')

	   -- Find the number of day from 1753-01-01 to @START_DATE and @END_DATE
	   select	@start_no	= datediff(dd,@LOW_DATE,@START_DATE),
		   @end_no	= datediff(dd,@LOW_DATE,@END_DATE)

	   -- Declare number tables
	   declare @num1 table (NUMBER int not null primary key clustered)
	   declare @num2 table (NUMBER int not null primary key clustered)
	   declare @num3 table (NUMBER int not null primary key clustered)

	   -- Declare table of ISO Week ranges
	   declare @ISO_WEEK table
	   (
	   [ISO_WEEK_YEAR] 			int			not null primary key clustered,
	   [ISO_WEEK_YEAR_START_DATE]	datetime	not null,
	   [ISO_WEEK_YEAR_END_DATE]	Datetime	not null
	   )

	   -- Find rows needed in number tables
	   declare	@rows_needed		int
	   declare	@rows_needed_root	int
	   select	@rows_needed		= @end_no - @start_no + 1
	   select  @rows_needed		=
			   case
			   when @rows_needed < 10
			   then 10
			   else @rows_needed
			   end
	   select	@rows_needed_root	= convert(int,ceiling(sqrt(@rows_needed)))

	   -- Load number 0 to 16
	   insert into @num1 (NUMBER)
	   select NUMBER = 0 union all select  1 union all select  2 union all
	   select          3 union all select  4 union all select  5 union all
	   select          6 union all select  7 union all select  8 union all
	   select          9 union all select 10 union all select 11 union all
	   select         12 union all select 13 union all select 14 union all
	   select         15
	   order by
		   1
	   -- Load table with numbers zero thru square root of the number of rows needed +1
	   insert into @num2 (NUMBER)
	   select
		   NUMBER = a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER)
	   from
		   @num1 a cross join @num1 b cross join @num1 c
	   where
		   a.NUMBER+(16*b.NUMBER)+(256*c.NUMBER) <
		   @rows_needed_root
	   order by
		   1

	   -- Load table with the number of rows needed for the date range
	   insert into @num3 (NUMBER)
	   select
		   NUMBER = a.NUMBER+(@rows_needed_root*b.NUMBER)
	   from
		   @num2 a
		   cross join
		   @num2 b
	   where
		   a.NUMBER+(@rows_needed_root*b.NUMBER) < @rows_needed
	   order by
		   1

	   declare	@iso_start_year	int
	   declare	@iso_end_year	int

	   select	@iso_start_year	= datepart(year,dateadd(year,-1,@start_date))
	   select	@iso_end_year	= datepart(year,dateadd(year,1,@end_date))

	   -- Load table with start and end dates for ISO week years
	   insert into @ISO_WEEK
		   (
		   [ISO_WEEK_YEAR],
		   [ISO_WEEK_YEAR_START_DATE],
		   [ISO_WEEK_YEAR_END_DATE]
		   )
	   select
		   [ISO_WEEK_YEAR] = a.NUMBER,
		   [0ISO_WEEK_YEAR_START_DATE]	=
			   dateadd(dd,(datediff(dd,@LOW_DATE,
			   dateadd(day,3,dateadd(year,a.[NUMBER]-1900,0))
			   )/7)*7,@LOW_DATE),
		   [ISO_WEEK_YEAR_END_DATE]	=
			   dateadd(dd,-1,dateadd(dd,(datediff(dd,@LOW_DATE,
			   dateadd(day,3,dateadd(year,a.[NUMBER]+1-1900,0))
			   )/7)*7,@LOW_DATE))
	   from
		   (
		   select
			   NUMBER = NUMBER+@iso_start_year
		   from
			   @num3
		   where
			   NUMBER+@iso_start_year <= @iso_end_year
		   ) a
	   order by
		   a.NUMBER

	   -- Load Date table
	   INSERT INTO #DATE (
	   	DateId, DateValue, NextDayDate, CalendarYear, CalendarYearQuarter, CalendarYearMonth, CalendarYearDayOfYear,
	   	CalendarQuarter, CalendarMonth, CalendarWeek, CalendarDayOfYear, CalendarDayOfMonth, CalendarDayOfWeek,
	   	CalendarYearName, CalendarYearQuarterName, CalendarYearMonthName, CalendarYearMonthNameLong, CalendarQuarterName,
	   	CalendarMonthName, CalendarMonthNameLong, WeekdayName, WeekdayNameLong, CalendarStartOfYearDate, CalendarEndOfYearDate,
	   	CalendarStartOfQuarterDate, CalendarEndOfQuarterDate, CalendarStartOfMonthDate, CalendarEndOfMonthDate, QuarterSeqNo,
	   	MonthSeqNo, WeekSeqNo, FiscalYearName, FiscalYearPeriod, FiscalYearDayOfYear, FiscalSemester, FiscalQuarter,
	   	FiscalPeriod, FiscalDayOfYear, FiscalDayOfPeriod, FiscalStartOfYearDate, FiscalEndOfYearDate, FiscalStartOfPeriodDate,
	   	FiscalEndOfPeriodDate, ISODate, ISOYearWeekNo, ISOWeekNo, ISODayOfWeek, ISOYearWeekName, ISOYearWeekDayOfWeekName,
	   	DateFormatYYYYMMDD, DateFormatYYYYMD, DateFormatMMDDYEAR, DateFormatMDYEAR, DateFormatMMMDYYYY,
	   	DateFormatMMMMMMMMMDYYYY, DateFormatMMDDYY, DateFormatMDYY, WorkDay, IsWorkDay, weekendFlag, relativeDayCount,
	   	relativeWeekCount, relativeMonthCount, isLastDayOfMonth, knightbrookeFiscalYear, exportLastDayofNextMonth,
	   	DateExportYYYYMMDD, daysInMonth, IsUSHoliday
	   )
	   SELECT
		   [DateId] = a.[DateId],
		   DateValue = a.DateValue,
		   [NextDayDate] =	dateadd(day,1,a.DateValue),
		   [CalendarYear] = datepart(year,a.DateValue),
		   [CalendarYearQuarter] = (10*datepart(year,a.DateValue))+datepart(quarter,a.DateValue),
		   [CalendarYearMonth]	= (100*datepart(year,a.DateValue))+datepart(month,a.DateValue),
		   [CalendarYearDayOfYear] = (1000*datepart(year,a.DateValue)) + datePart(dayofyear, a.DateValue),
		   [CalendarQuarter] = datepart(quarter,a.DateValue),
		   [CalendarMonth]	= datepart(month,a.DateValue),
		   [CalendarWeek] = datepart(iso_week, dateAdd(d, 1, a.DateValue)),
		   [CalendarDayOfYear]	= datePart(dayofyear, a.DateValue),
		   [CalendarDayOfMonth] = datepart(day,a.DateValue),
		   [CalendarDayOfWeek]	= (datediff(dd,'17530107',a.DateValue)%7)+1, -- Sunday = 1, Monday = 2, ,,,Saturday = 7
		   [CalendarYearName] = datename(year,a.DateValue),
		   [CalendarYearQuarterName] = datename(year,a.DateValue)+' Q'+datename(quarter,a.DateValue),
		   [CalendarYearMonthName]	= datename(year,a.DateValue)+' '+left(datename(month,a.DateValue),3),
		   [CalendarYearMonthNameLong]	= datename(year,a.DateValue)+' '+datename(month,a.DateValue),
		   [CalendarQuarterName] = 'Q'+datename(quarter,a.DateValue),
		   [CalendarMonthName] = left(datename(month,a.DateValue),3),
		   [CalendarMonthNameLong]	= datename(month,a.DateValue),
		   [WeekdayName] =	left(datename(weekday,a.DateValue),3),
		   [WeekdayNameLong] =	datename(weekday,a.DateValue),
		   [CalendarStartOfYearDate] = dateadd(year,datediff(year,0,a.DateValue),0),
		   [CalendarEndOfYearDate]	= dateadd(day,-1,dateadd(year,datediff(year,0,a.DateValue)+1,0)),
		   [CalendarStartOfQuarterDate] = dateadd(quarter,datediff(quarter,0,a.DateValue),0),
		   [CalendarEndOfQuarterDate]	= dateadd(day,-1,dateadd(quarter,datediff(quarter,0,a.DateValue)+1,0)),
		   [CalendarStartOfMonthDate] = dateadd(month,datediff(month,0,a.DateValue),0),
		   [CalendarEndOfMonthDate] = dateadd(day,-1,dateadd(month,datediff(month,0,a.DateValue)+1,0)),
		   [QuarterSeqNo] = datediff(quarter,@LOW_DATE,a.DateValue),
		   [MonthSeqNo] = datediff(month,@LOW_DATE,a.DateValue),
		   [WeekSeqNo] = datediff(week,@LOW_DATE,a.DateValue),
 		   [FiscalYearName] = datename(year,a.DateValue),
		   [FiscalYearPeriod] = (datepart(year,a.DateValue))+ (cast((datepart(month,a.DateValue)/100.00) as decimal (2,2))),
		   [FiscalYearDayOfYear] = (datepart(year,a.DateValue)+ cast((datePart(dayofyear, a.DateValue))/1000.00 as numeric (3,3))),
		   --[FiscalYearWeekName] = '',
		   [FiscalSemester] = case when datepart(quarter,a.DateValue) <= 2 then 1 else 2 end,
		   [FiscalQuarter] = datepart(quarter,a.DateValue),
		   [FiscalPeriod] = datepart(month,a.DateValue),
		   [FiscalDayOfYear] = datePart(dayofyear, a.DateValue),
		   [FiscalDayOfPeriod] = datepart(day,a.DateValue),
		   --[FiscalWeekName] = 0, --cast(datepart(month,a.DateValue) as char(2)) + '.0',
		   [FiscalStartOfYearDate]	= dateadd(year,datediff(year,0,a.DateValue),0),
		   [FiscalEndOfYearDate] =  dateadd(day,-1,dateadd(year,datediff(year,0,a.DateValue)+1,0)),
		   [FiscalStartOfPeriodDate] = dateadd(month,datediff(month,0,a.DateValue),0),
		   [FiscalEndOfPeriodDate]	= dateadd(day,-1,dateadd(month,datediff(month,0,a.DateValue)+1,0)),    
		   [ISODate] = replace(convert(char(10),a.DateValue,111),'/','-'),
		   [ISOYearWeekNo]	= (100*b.[ISO_WEEK_YEAR])+datepart(iso_week, a.DateValue),
		   [ISOWeekNo]	= datepart(iso_week, a.DateValue),
		   [ISODayOfWeek] = (datediff(dd,@LOW_DATE,a.DateValue)%7)+1, /* Monday = 1, Tuesday = 2 ,,,Sunday = 7 */
		   [ISOYearWeekName] = convert(varchar(4),b.[ISO_WEEK_YEAR])+'-W'+ right('00'+convert(varchar(2),datepart(iso_week, a.DateValue)),2),
		   [ISOYearWeekDayOfWeekName]	= convert(varchar(4),b.[ISO_WEEK_YEAR])+'-W'+
			   right('00'+convert(varchar(2),datepart(iso_week, a.DateValue)),2) +
			   '-'+convert(varchar(1),(datediff(dd,@LOW_DATE,a.DateValue)%7)+1),
		   [DateFormatYYYYMMDD]	= convert(char(10),a.DateValue,111),
		   [DateFormatYYYYMD]		= convert(varchar(10),
			   convert(varchar(4),year(a.DateValue))+'/'+
			   convert(varchar(2),day(a.DateValue))+'/'+
			   convert(varchar(2),month(a.DateValue))),
		   [DateFormatMMDDYEAR]	= convert(char(10),a.DateValue,101),
		   [DateFormatMDYEAR]		= convert(varchar(10),
			   convert(varchar(2),month(a.DateValue))+'/'+
			   convert(varchar(2),day(a.DateValue))+'/'+
			   convert(varchar(4),year(a.DateValue))),
		   [DateFormatMMMDYYYY]	= 
			   convert(varchar(12),
			   left(datename(month,a.DateValue),3)+' '+
			   convert(varchar(2),day(a.DateValue))+', '+
			   convert(varchar(4),year(a.DateValue))),
		   [DateFormatMMMMMMMMMDYYYY]	= convert(varchar(18),
			   datename(month,a.DateValue)+' '+
			   convert(varchar(2),day(a.DateValue))+', '+
			   convert(varchar(4),year(a.DateValue))),
		   [DateFormatMMDDYY]	= convert(char(8),a.DateValue,1),
		   [DateFormatMDYY]	= convert(varchar(8),
			   convert(varchar(2),month(a.DateValue))+'/'+
			   convert(varchar(2),day(a.DateValue))+'/'+
			   right(convert(varchar(4),year(a.DateValue)),2)),
		  [WorkDay] = CASE WHEN datepart(weekday, a.DateValue) IN (1, 7) THEN 'No Work' ELSE 'Work Day' END, --17530107 use this because the weekday is a Sunday
		  [IsWorkDay]= CASE WHEN datepart(weekday, a.DateValue) IN (1, 7) THEN 0 ELSE 1 END,
		  [weekendFlag]= CASE WHEN datepart(weekday, a.DateValue) IN (1, 7) THEN 1 ELSE 0 END,
		  [RelativeDayCount] =  DATEDIFF(day,@startDate,a.DateValue),
		  [RelativeWeekCount] = DATEDIFF(week,@startDate,a.DateValue),
		  [RelativeMonthCount] = DATEDIFF(month,@startDate,a.DateValue),
		  [isLastDayOfMonth] = CASE WHEN datepart(day,a.DateValue + 1) < datepart(day,a.DateValue) THEN 1 ELSE 0 END,
		  [knightbrookeFiscalYear] = CASE WHEN DATEPART(MONTH,a.DateValue) = 12 THEN DATEPART(YEAR,a.DateValue) + 1 ELSE DATEPART(YEAR,a.DateValue) END,
		  [exportLastDayofNextMonth] = CONVERT(VARCHAR(25),DATEADD(s,-1,DATEADD(m,DATEDIFF(m,0,a.DateValue)+2,0)),112),
		  [DateExportYYYYMMDD] = CONVERT(varchar(8), a.DateValue, 112),
		  [daysInMonth] = DATEDIFF(day, dateadd(month,datediff(month,0,a.DateValue),0),dateadd(day,-1,dateadd(month,datediff(month,0,a.DateValue)+1,0))) + 1,
		  IsUSHoliday = 0
	   FROM
		   (
		   -- Derived table is all dates needed for date range
		   select	top 100 percent
			   [DateId]	= aa.[NUMBER],
			   DateValue    = dateadd(dd,aa.[NUMBER],@LOW_DATE)
		   from
			   (
			   select
				   NUMBER = NUMBER+@start_no 
			   from
				   @num3
			   where
				   NUMBER+@start_no <= @end_no
			   ) aa
		   order by
			   aa.[NUMBER]
		   ) a
		   join
		   -- Match each date to the proper ISO week year
		   @ISO_WEEK b
		   on a.DateValue between 
			   b.[ISO_WEEK_YEAR_START_DATE] and 
			   b.[ISO_WEEK_YEAR_END_DATE]
	   ORDER BY a.[DateId]
	   
		UPDATE D SET
			FirstOfMonth = CONVERT(DATE, DATEADD(MONTH, DATEDIFF(MONTH, 0, [dateValue]), 0)),
			FirstOfYear = CONVERT(DATE, DATEADD(YEAR,  DATEDIFF(YEAR,  0, [dateValue]), 0))
		FROM #DATE AS D;
	   
	   WITH cteDates AS (
			SELECT
				D.DateValue,
				DOWInMonth  = CONVERT(TINYINT, ROW_NUMBER() OVER (PARTITION BY FirstOfMonth, [CalendarDayOfWeek] ORDER BY [D].[DateValue])),
				FirstDayOfMonth = FirstOfMonth,
				FirstDayOfYear = FirstOfYear,
				LastDayOfMonth      = MAX([dateValue]) OVER (PARTITION BY D.CalendarYear, D.CalendarMonth),
				FirstDayOfQuarter   = MIN([dateValue]) OVER (PARTITION BY D.CalendarYear, D.[CalendarQuarter]),
				LastDayOfQuarter    = MAX([dateValue]) OVER (PARTITION BY D.CalendarYear, D.[CalendarQuarter]),
				LastDayOfYear       = MAX([dateValue]) OVER (PARTITION BY D.CalendarYear),
				FirstDayOfNextMonth = DATEADD(MONTH, 1, FirstOfMonth),
				FirstDayOfNextYear  = DATEADD(YEAR,  1, FirstOfYear)
			FROM #DATE AS D   
	   )
	   UPDATE D SET
			D.DOWInMonth = D1.DOWInMonth,
			D.FirstDayOfMonth = D1.FirstDayOfMonth,
			D.FirstDayOfYear = D1.FirstDayOfYear,
			D.LastDayOfMonth = D1.LastDayOfMonth,
			D.FirstDayOfQuarter = D1.FirstDayOfQuarter,
			D.LastDayOfQuarter = D1.LastDayOfQuarter,
			D.LastDayOfYear = D1.LastDayOfYear,
			D.FirstDayOfNextMonth = D1.FirstDayOfNextMonth,
			D.FirstDayOfNextYear = D1.FirstDayOfNextYear
	   FROM cteDates AS D1
		JOIN #DATE AS D ON D.DateValue = D1.DateValue
		
		;WITH x AS 
		(
		  SELECT [DateValue] AS [Date], IsUSHoliday AS IsHoliday, HolidayText, FirstDayOfYear,
			DOWInMonth, [#DATE].[CalendarMonthNameLong] AS [MonthName], #DATE.WeekdayNameLong AS [WeekDayName], #DATE.CalendarDayOfMonth,
			LastDOWInMonth = ROW_NUMBER() OVER 
			(
			  PARTITION BY #DATE.CalendarDayOfMonth, [IsWorkDay] 
			  ORDER BY [DateValue] DESC
			)
		  FROM #DATE
		)
		UPDATE x SET IsHoliday = 1, HolidayText = CASE
		  WHEN ([Date] = FirstDayOfYear) 
			THEN 'New Year''s Day'
		  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'January' AND [WeekDayName] = 'Monday')
			THEN 'Martin Luther King Day'    -- (3rd Monday in January)
		  WHEN ([DOWInMonth] = 3 AND [MonthName] = 'February' AND [WeekDayName] = 'Monday')
			THEN 'President''s Day'          -- (3rd Monday in February)
		  WHEN ([LastDOWInMonth] = 1 AND [MonthName] = 'May' AND [WeekDayName] = 'Monday')
			THEN 'Memorial Day'              -- (last Monday in May)
		  WHEN ([MonthName] = 'July' AND CalendarDayOfMonth = 4)
			THEN 'Independence Day'          -- (July 4th)
		  WHEN ([DOWInMonth] = 1 AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
			THEN 'Labour Day'                -- (first Monday in September)
		  WHEN ([DOWInMonth] = 2 AND [MonthName] = 'October' AND [WeekDayName] = 'Monday')
			THEN 'Columbus Day'              -- Columbus Day (second Monday in October)
		  WHEN ([MonthName] = 'November' AND CalendarDayOfMonth = 11)
			THEN 'Veterans'' Day'            -- Veterans' Day (November 11th)
		  WHEN ([DOWInMonth] = 4 AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
			THEN 'Thanksgiving Day'          -- Thanksgiving Day (fourth Thursday in November)
		  WHEN ([MonthName] = 'December' AND CalendarDayOfMonth = 25)
			THEN 'Christmas Day'
		  END
		WHERE 
		  ([Date] = FirstDayOfYear)
		  OR ([DOWInMonth] = 3     AND [MonthName] = 'January'   AND [WeekDayName] = 'Monday')
		  OR ([DOWInMonth] = 3     AND [MonthName] = 'February'  AND [WeekDayName] = 'Monday')
		  OR ([LastDOWInMonth] = 1 AND [MonthName] = 'May'       AND [WeekDayName] = 'Monday')
		  OR ([MonthName] = 'July' AND CalendarDayOfMonth = 4)
		  OR ([DOWInMonth] = 1     AND [MonthName] = 'September' AND [WeekDayName] = 'Monday')
		  OR ([DOWInMonth] = 2     AND [MonthName] = 'October'   AND [WeekDayName] = 'Monday')
		  OR ([MonthName] = 'November' AND CalendarDayOfMonth = 11)
		  OR ([DOWInMonth] = 4     AND [MonthName] = 'November' AND [WeekDayName] = 'Thursday')
		  OR ([MonthName] = 'December' AND CalendarDayOfMonth = 25);
		  

		UPDATE D SET IsUSHoliday = 1, HolidayText = 'Black Friday'
		FROM #DATE AS d
			INNER JOIN
			(
			  SELECT [DateValue] AS [Date], #DATE.CalendarYear AS [Year], #DATE.CalendarDayOfYear AS [DayOfYear]
			  FROM #DATE
			  WHERE HolidayText = 'Thanksgiving Day'
			) AS src 
		ON d.CalendarYear = src.[Year] 
		AND d.CalendarDayOfYear = src.[DayOfYear] + 1;
		
	     
		;WITH x AS 
		(
		  SELECT d.[DateValue], d.IsUSHoliday, d.HolidayText, h.HolidayName
			FROM #DATE AS d
				CROSS APPLY utils.GetEasterHolidays(d.CalendarYear) AS h
			WHERE d.[DateValue] = h.[Date]
		)
		UPDATE x SET IsUSHoliday = 1, HolidayText = HolidayName;

	   IF EXISTS
		  (SELECT 1
		  FROM INFORMATION_SCHEMA.TABLES
		  WHERE TABLE_TYPE = 'BASE TABLE' 
		  AND TABLE_NAME = 'Calendar'
		  AND TABLE_SCHEMA = 'utils')
	   BEGIN
		  DROP TABLE utils.Calendar;
	   END
 
	   SELECT DTE.dateValue,
			 DTE.nextDayDate,
			 DTE.calendarYear,
			 DTE.calendarYearQuarter,
			 DTE.calendarYearMonth,
			 DTE.calendarYearDayOfYear,
			 DTE.calendarQuarter,
			 DTE.calendarMonth,
			 DTE.CalendarWeek,
			 DTE.calendarDayOfYear,
			 DTE.calendarDayOfMonth,
			 DTE.calendarDayOfWeek,
			 DTE.calendarYearName,
			 DTE.calendarYearQuarterName,
			 DTE.calendarYearMonthName,
			 DTE.calendarYearMonthNameLong,
			 DTE.calendarQuarterName,
			 DTE.calendarMonthName,
			 DTE.calendarMonthNameLong,
			 DTE.weekdayName,
			 DTE.weekdayNameLong,
			 DTE.calendarStartOfYearDate,
			 DTE.calendarEndOfYearDate,
			 DTE.calendarStartOfQuarterDate,
			 DTE.calendarEndOfQuarterDate,
			 DTE.calendarStartOfMonthDate,
			 DTE.calendarEndOfMonthDate,
			 DTE.quarterSeqNo,
			 DTE.monthSeqNo,
			 DTE.weekSeqNo,
			 DTE.fiscalYearName,
			 DTE.fiscalYearPeriod,
			 DTE.fiscalYearDayOfYear,
			 --DTE.fiscalYearWeekName,
			 DTE.fiscalSemester,
			 DTE.fiscalQuarter,
			 DTE.fiscalPeriod,
			 DTE.fiscalDayOfYear,
			 DTE.fiscalDayOfPeriod,
			 --DTE.fiscalWeekName,
			 DTE.fiscalStartOfYearDate,
			 DTE.fiscalEndOfYearDate,
			 DTE.fiscalStartOfPeriodDate,
			 DTE.fiscalEndOfPeriodDate,
			 DTE.iSODate,
			 DTE.iSOYearWeekNo,
			 DTE.iSOWeekNo,
			 DTE.iSODayOfWeek,
			 DTE.iSOYearWeekName,
			 DTE.iSOYearWeekDayOfWeekName,
			 DTE.dateFormatYYYYMMDD,
			 DTE.dateFormatYYYYMD,
			 DTE.dateFormatMMDDYEAR,
			 DTE.dateFormatMDYEAR,
			 DTE.dateFormatMMMDYYYY,
			 DTE.dateFormatMMMMMMMMMDYYYY,
			 DTE.dateFormatMMDDYY,
			 DTE.dateFormatMDYY,
			 DTE.workDay,
			 DTE.isWorkDay,
			 DTE.weekendFlag,
			 DTE.relativeDayCount,
			 DTE.relativeWeekCount,
			 DTE.relativeMonthCount,
			 DTE.isLastDayOfMonth,
			 DTE.knightbrookeFiscalYear,
			 DTE.exportLastDayofNextMonth,
			 DTE.DateExportYYYYMMDD,
			 DTE.daysInMonth,
			 DTE.IsUSHoliday,
			 DTE.HolidayText,
			DTE.FirstDayOfNextMonth,
			DTE.FirstDayOfNextYear,
			DTE.DOWInMonth
	    INTO utils.Calendar
	    From #Date DTE
	    ORDER BY 1

	   ALTER TABLE utils.Calendar
	   ADD  PRIMARY KEY CLUSTERED (DateValue)
	   WITH FILLFACTOR = 100;
 
	   CREATE INDEX idx_Dates ON utils.Calendar (NextDayDate);
	   
		SELECT TOP 365 *
		FROM utils.Calendar AS C
		WHERE C.calendarYear = DATEPART(YEAR, GETDATE())
		ORDER BY C.dateValue

END
GO

EXEC [utils].[CalendarSetup]
