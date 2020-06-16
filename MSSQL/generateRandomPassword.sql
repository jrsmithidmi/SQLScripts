select cast((Abs(Checksum(NewId()))%10) as varchar(1)) + 
       char(ascii('a')+(Abs(Checksum(NewId()))%25)) +
       char(ascii('A')+(Abs(Checksum(NewId()))%25)) +
       left(newid(),5)