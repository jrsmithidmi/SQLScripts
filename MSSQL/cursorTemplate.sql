DECLARE 
	@policyID INT,
	@cur_TempCursor CURSOR
	
SET @cur_TempCursor = CURSOR FAST_FORWARD FOR
SELECT 'HERE'


OPEN @cur_TempCursor

FETCH NEXT FROM @cur_TempCursor INTO @policyID
	
WHILE @@FETCH_STATUS = 0
BEGIN				
	'OTHER STUFF HERE'		

	FETCH NEXT FROM @cur_TempCursor INTO @policyID
END

CLOSE @cur_TempCursor
DEALLOCATE @cur_TempCursor