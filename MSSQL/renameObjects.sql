DECLARE 
	@schemaName NVARCHAR(25) = N'renter',
	@originalTable NVARCHAR(100) = N'TerritoryBaseRates'

DECLARE
	@somethingChange NVARCHAR(100) = @schemaName + '.' + @originalTable,
	@oldTable NVARCHAR(100) = @originalTable + '_Old',
	@newTable NVARCHAR(100) = @schemaName + '.' + @originalTable + '_JRS'
		
SELECT @newTable AS newTable, @oldTable AS oldTable, @originalTable AS originalTable, @somethingChange AS somethingChange, @schemaName AS schemaName

EXEC sp_rename @somethingChange, @oldTable

EXEC sp_rename @newTable, @originalTable

GO

/* Table */
EXEC sys.sp_rename
    @objname = N'erroromissions.EOBasePrem', -- nvarchar(1035)
    @newname = 'BasePrem'
GO
/* Column */
EXEC sys.sp_rename
	@objname = N'dbo.CompanyFeeAmount.feeTypeID', -- nvarchar(1035)
    @newname = 'companyFeeTypeID', -- sysname
    @objtype = 'COLUMN' -- varchar(13)    
GO		
/* Schema */
ALTER SCHEMA erroromissions
    TRANSFER dbo.EOBasePrem;
GO
