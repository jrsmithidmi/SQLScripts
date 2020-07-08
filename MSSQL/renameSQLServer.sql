sp_helpserver
select @@servername


sp_dropserver 'WIN-JCORF3P2GNV\SQLTRAINING'
go
sp_addserver 'SQL4\SQLTRAINING','local'
go


/* Requires service restart */