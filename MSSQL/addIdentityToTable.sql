/*
	This only works if you are changing a single column to be an identity. 
	If you change any other property on the table, this will not work.
*/

--Create a duplicate of the table that needs to be fixed
CREATE TABLE [condo].[AnimalLiability_Fix](
	[TC_AnimalLiabilityID] [INT] NOT NULL IDENTITY(10,1),
	[limit] [DECIMAL](19, 2) NULL,
	[allPerilsPremium] [DECIMAL](19, 2) NULL,
	[policyProgram] [TINYINT] NULL,
	[ratingVersionID] [INT] NULL
) 

-- Swaps the table and data to the new table with the identity column assuming the original ID field is unique values
ALTER TABLE condo.AnimalLiability SWITCH TO condo.AnimalLiability_Fix

-- Drop original table
DROP TABLE condo.AnimalLiability;

-- Rename new table to the original name
EXEC sp_rename 'condo.AnimalLiability_Fix','AnimalLiability';

-- Sets the identity value to the next value in the table
DBCC CHECKIDENT('condo.AnimalLiability');

-- Checks data
SELECT * FROM condo.AnimalLiability; 

-- Sets ratingVersionID to not be null
ALTER TABLE condo.AnimalLiability
ALTER COLUMN ratingVersionID INT NOT NULL

-- Creates primary key index
ALTER TABLE condo.AnimalLiability
ADD CONSTRAINT PK_AnimalLiability PRIMARY KEY CLUSTERED (ratingVersionID, TC_AnimalLiabilityID)