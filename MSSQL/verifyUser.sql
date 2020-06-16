EXECUTE AS USER='Aggressive_newgui'

SELECT *
FROM dbo.Users AS U
WHERE U.username = 'Aggressive_Jrsmith'

REVERT