/**
Based on code by Phil Factor (https://www.red-gate.com/hub/product-learning/sql-prompt/record-t-sql-execution-times-using-sql-prompt-snippet).
**/
DECLARE @log table
(
    TheOrder     int IDENTITY(1, 1),
    WhatHappened varchar(200),
    WhenItDid    datetime2 DEFAULT GETDATE()
)
----start of timing
INSERT INTO @log(WhatHappened)
SELECT 'Starting $routine$' --place at the start
 
$SELECTEDTEXT$$CURSOR$
 
--where the routine you want to time ends
INSERT INTO @log(WhatHappened)
SELECT '$routine$ took '
SELECT ending.WhatHappened, DATEDIFF(ms, starting.WhenItDid, ending.WhenItDid)
FROM   @log starting
       INNER JOIN @log ending
           ON ending.TheOrder = starting.TheOrder + 1
--list out all the timings