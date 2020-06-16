-----------------------------------
-- All the user options settings --
-----------------------------------

DECLARE @UserOptionBitValue TABLE 
    (BitValue INT,
     Setting VARCHAR(100),
     SettingDescription VARCHAR(500))

---------------------------------------------------------------------------------
-- User Options definitions 
-- http://msdn.microsoft.com/en-us/library/ms176031.aspx
---------------------------------------------------------------------------------
INSERT @UserOptionBitValue VALUES (1,'DISABLE_DEF_CNST_CHK','Controls interim or deferred constraint checking.')
INSERT @UserOptionBitValue VALUES (2,'IMPLICIT_TRANSACTIONS','For dblib network library connections, controls whether a transaction is started implicitly when a statement is executed. The IMPLICIT_TRANSACTIONS setting has no effect on ODBC or OLEDB connections.')
INSERT @UserOptionBitValue VALUES (4,'CURSOR_CLOSE_ON_COMMIT','Controls behavior of cursors after a commit operation has been performed.')
INSERT @UserOptionBitValue VALUES (8,'ANSI_WARNINGS','Controls truncation and NULL in aggregate warnings.')
INSERT @UserOptionBitValue VALUES (16,'ANSI_PADDING','Controls padding of fixed-length variables.')
INSERT @UserOptionBitValue VALUES (32,'ANSI_NULLS','Controls NULL handling when using equality operators.')
INSERT @UserOptionBitValue VALUES (64,'ARITHABORT','Terminates a query when an overflow or divide-by-zero error occurs during query execution.')
INSERT @UserOptionBitValue VALUES (128,'ARITHIGNORE','Returns NULL when an overflow or divide-by-zero error occurs during a query.')
INSERT @UserOptionBitValue VALUES (256,'QUOTED_IDENTIFIER','Differentiates between single and double quotation marks when evaluating an expression.')
INSERT @UserOptionBitValue VALUES (512,'NOCOUNT','Turns off the message returned at the end of each statement that states how many rows were affected.')
INSERT @UserOptionBitValue VALUES (1024,'ANSI_NULL_DFLT_ON','Alters the session''s behavior to use ANSI compatibility for nullability. New columns defined without explicit nullability are defined to allow nulls.')
INSERT @UserOptionBitValue VALUES (2048,'ANSI_NULL_DFLT_OFF','Alters the session''s behavior not to use ANSI compatibility for nullability. New columns defined without explicit nullability do not allow nulls.')
INSERT @UserOptionBitValue VALUES (4096,'CONCAT_NULL_YIELDS_NULL','Returns NULL when concatenating a NULL value with a string.')
INSERT @UserOptionBitValue VALUES (8192,'NUMERIC_ROUNDABORT','Generates an error when a loss of precision occurs in an expression.')
INSERT @UserOptionBitValue VALUES (16384,'XACT_ABORT','Rolls back a transaction if a Transact-SQL statement raises a run-time error.')

SELECT
    BitValue,
    Setting,

    [DefaultState]= CASE CAST(cfg.value AS INT) & BitValue
    WHEN 0 THEN 'OFF'
    ELSE 'ON' END,

    [CurrentState] = CASE @@OPTIONS & BitValue
    WHEN 0 THEN 'OFF'
    ELSE 'ON' END,

    SettingDescription
FROM
    sys.configurations cfg
    CROSS JOIN @UserOptionBitVAlue def
WHERE
    name = 'user options'


GO

SELECT [ARITHABORT] = CASE CAST(cfg.value AS INT) & 64 --bitwise operation on the 7th position
    WHEN 0 THEN 'OFF'
    ELSE 'ON' END
FROM sys.configurations cfg
WHERE name = 'user options'


GO


/* SP Settings */
SELECT name = OBJECT_NAME([object_id]), uses_ansi_nulls, uses_quoted_identifier, 
        is_schema_bound, uses_database_collation, is_recompiled, 
        null_on_null_input, execute_as_principal_id, definition
FROM sys.sql_modules