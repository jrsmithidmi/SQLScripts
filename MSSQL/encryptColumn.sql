--Create the keys and certificate.  
USE Aggressive;
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'h8QasUPrU5aDR$sp+mEC&??4u';
OPEN MASTER KEY DECRYPTION BY PASSWORD = 'h8QasUPrU5aDR$sp+mEC&??4u';
CREATE CERTIFICATE Aggressive
	WITH
		SUBJECT = 'Aggressive Encryption', EXPIRY_DATE = '12/31/2099';
CREATE SYMMETRIC KEY AggressiveEncryption
	WITH ALGORITHM = AES_256
	ENCRYPTION BY CERTIFICATE Aggressive;
GO
----Add a column of encrypted data.  
ALTER TABLE dbo.PaymentInfo ADD encBankAcctNum1 VARBINARY(256);

OPEN SYMMETRIC KEY AggressiveEncryption
	DECRYPTION BY CERTIFICATE Aggressive;

UPDATE dbo.PaymentInfo
SET	   PaymentInfo.encBankAcctNum = ENCRYPTBYKEY (KEY_GUID ('AggressiveEncryption'), PaymentInfo.bankAcctNum);
GO
--  
--Close the key used to encrypt the data.  
CLOSE SYMMETRIC KEY AggressiveEncryption;
--  
--There are two ways to decrypt the stored data.  
--  
--OPTION ONE, using DecryptByKey()  
--1. Open the symmetric key  
--2. Decrypt the data  
--3. Close the symmetric key  
OPEN SYMMETRIC KEY AggressiveEncryption
	DECRYPTION BY CERTIFICATE Aggressive;

SELECT
	  PI.paymentInfoID,
	  PI.encBankAcctNum,
	  CONVERT (VARCHAR, DECRYPTBYKEY (PI.encBankAcctNum)) AS 'BankAcctNum',
	  DECRYPTBYKEY (PI.encBankAcctNum)
FROM  dbo.PaymentInfo AS PI
WHERE PI.bankAcctNum IS NOT NULL;

CLOSE SYMMETRIC KEY AggressiveEncryption;
--  
--OPTION TWO, using DecryptByKeyAutoCert()  

SELECT
	  PI.paymentInfoID,
	  PI.encBankAcctNum,
	  PI.bankAcctNum,
	  CONVERT (VARCHAR, DECRYPTBYKEYAUTOCERT (CERT_ID ('Aggressive'), NULL, PI.encBankAcctNum)) AS 'BankAcctNum'
FROM  dbo.PaymentInfo AS PI
WHERE PI.bankAcctNum IS NOT NULL;

