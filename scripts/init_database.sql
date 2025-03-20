
-- Create Database 'DataWarehouse'
USE master;
GO

-- Drop and recreate the 'DataWarhouse' database
IF EXISTS(SELECT 1 FROM sys.databases 
WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse Set SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;

GO

-- Create 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Creating Required Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
