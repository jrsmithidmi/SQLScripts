-- Server / Instance Logins (results not sensitive to local / current Database)
;WITH certs_n_keys AS
(
  SELECT 'Certifcate' AS [Type], crts.name, crts.certificate_id AS [cert_or_asymkey_id],
         crts.principal_id, crts.pvt_key_encryption_type_desc, crts.[sid],
         crts.thumbprint
  FROM   [master].sys.certificates crts
  UNION ALL
  SELECT 'Asymmetric Key' AS [Type], asym.name, asym.asymmetric_key_id AS
         [cert_or_asymkey_id], asym.principal_id, asym.pvt_key_encryption_type_desc,
         asym.[sid], asym.thumbprint
  FROM   [master].sys.asymmetric_keys asym
)
SELECT cnk.*, '---' AS [---],
       sp.[name] AS [PrincipalName], sp.principal_id, sp.type_desc,
       sp.create_date, sp.modify_date
FROM   certs_n_keys cnk
INNER JOIN sys.server_principals sp
        ON sp.[sid] = cnk.[sid];


-- Database Users
;WITH certs_n_keys AS
(
  SELECT 'Certifcate' AS [Type], crts.name, crts.certificate_id AS [cert_or_asymkey_id],
         crts.principal_id, crts.pvt_key_encryption_type_desc, crts.[sid],
         crts.thumbprint
  FROM   sys.certificates crts
  UNION ALL
  SELECT 'Asymmetric Key' AS [Type], asym.name, asym.asymmetric_key_id AS
         [cert_or_asymkey_id], asym.principal_id, asym.pvt_key_encryption_type_desc,
         asym.[sid], asym.thumbprint
  FROM   sys.asymmetric_keys asym
)
SELECT cnk.*, '---' AS [---],
       dp.[name] AS [PrincipalName], dp.principal_id, dp.type_desc,
       dp.create_date, dp.modify_date
FROM   certs_n_keys cnk
INNER JOIN sys.database_principals dp
        ON dp.[sid] = cnk.[sid];


-- Service Broker Endpoints
SELECT crts.name, crts.certificate_id, crts.principal_id,
       crts.pvt_key_encryption_type_desc, crts.[sid], crts.thumbprint, '---' AS [---],
       endpts.*
FROM   sys.certificates crts
INNER JOIN sys.service_broker_endpoints endpts
        ON endpts.certificate_id = crts.certificate_id;


-- Database Mirroring Endpoints
SELECT crts.name, crts.certificate_id, crts.principal_id,
       crts.pvt_key_encryption_type_desc, crts.[sid], crts.thumbprint, '---' AS [---],
       endpts.*
FROM   sys.certificates crts
INNER JOIN sys.database_mirroring_endpoints endpts
        ON endpts.certificate_id = crts.certificate_id;


-- Symmetric Keys (scroll results to the right to see Key name)
SELECT crts.name, crts.certificate_id, crts.principal_id,
       crts.pvt_key_encryption_type_desc, crts.[sid], crts.thumbprint, '---' AS [---],
       ncrptns.*, '---' AS [---], symkys.*
FROM   sys.certificates crts
INNER JOIN sys.key_encryptions ncrptns
        ON ncrptns.[thumbprint] = crts.[thumbprint]
INNER JOIN sys.symmetric_keys symkys
        ON symkys.[symmetric_key_id] = ncrptns.[key_id];


-- Database Encryption Keys (for TDE; results not sensitive to local / current Database)
SELECT crts.name, crts.certificate_id, crts.principal_id,
       crts.pvt_key_encryption_type_desc, crts.[sid], crts.thumbprint, '---' AS [---],
       DB_NAME(dbkeys.[database_id]) AS [DatabaseName], dbkeys.*
FROM   [master].sys.certificates crts
INNER JOIN sys.dm_database_encryption_keys dbkeys
        ON dbkeys.[encryptor_thumbprint] = crts.[thumbprint];