USE DBATools
GO

SELECT * 
FROM dbo.DDLAuditFunction AS DAF
WHERE CAST(EventDate AS DATE) > GETDATE() - 2

SELECT * 
FROM dbo.DDLAuditProcedure AS DAP
WHERE CAST(EventDate AS DATE) > GETDATE() - 2

SELECT * 
FROM dbo.DDLAuditTable AS DAT
WHERE CAST(EventDate AS DATE) > GETDATE() - 2

SELECT * 
FROM dbo.DDLAuditTrigger AS DAT
WHERE CAST(EventDate AS DATE) > GETDATE() - 2

SELECT * 
FROM dbo.DDLAuditView AS DAV
WHERE CAST(EventDate AS DATE) > GETDATE() - 2

GO


DECLARE 
	@objectName VARCHAR(100) = 'AuditEmail',
	@schemaName VARCHAR(100) = 'dbo',
	@databaseName VARCHAR(100) = 'DBATools'

;WITH Events AS (
	SELECT
		DAP.DDLAuditProcedureID, DAP.EventDate, DAP.DatabaseName, DAP.SchemaName, DAP.ObjectName, DAP.EventDDL,	DAP.EventXML, 
		rnLatest = ROW_NUMBER() OVER (PARTITION BY DAP.DatabaseName, DAP.SchemaName, DAP.ObjectName	ORDER BY DAP.EventDate DESC),
		rnEarliest = ROW_NUMBER() OVER (PARTITION BY DAP.DatabaseName, DAP.SchemaName, DAP.ObjectName ORDER BY DAP.EventDate),
		priorChangeID = LAG( DAP.DDLAuditProcedureID, 1 ) OVER (PARTITION BY DAP.DatabaseName, DAP.SchemaName, DAP.ObjectName ORDER BY DAP.EventDate)
	FROM DBATools.dbo.DDLAuditProcedure AS DAP
	WHERE DAP.DatabaseName = @databaseName
		AND DAP.ObjectName = @objectName
		AND DAP.SchemaName = @schemaName
)
SELECT
		Original.DatabaseName, Original.SchemaName, Original.ObjectName, 
		OriginalCode = Original.EventDDL,
		OriginalXML = Original.EventXML, OriginalModifiedDate = Original.EventDate,
		CurrentCode = COALESCE( Newest.EventDDL, '' ), CurrentXML = Newest.EventXML,
		LastModified = COALESCE( Newest.EventDate, Original.EventDate ), PriorCode = COALESCE( PriorChange.EventDDL, '' ),
		PriorXML = PriorChange.EventXML, PriorModified = COALESCE( PriorChange.EventDate, Newest.EventDate )
  FROM	Events AS Original
		LEFT JOIN Events AS Newest 
			ON Original.DatabaseName = Newest.DatabaseName
				AND	Original.SchemaName = Newest.SchemaName
				AND	Original.ObjectName = Newest.ObjectName
				AND	Newest.rnEarliest = Original.rnLatest
				AND	Newest.rnLatest = Original.rnEarliest
				AND	Newest.rnEarliest > 1
		LEFT JOIN Events AS PriorChange ON Newest.priorChangeID = PriorChange.DDLAuditProcedureID
 WHERE	Original.rnEarliest = 1;