/* CREATE DATABASE AND SCHEMAS*/

/*
SCRIPT PURPOSE:
This Script Creates a New 'DataWarehouse' Database
Before creating any database check if the database is already exits
if the database exists first remove that database and create a new database with same name
Then it will create important three schemas 'bronze', 'silver', 'gold'

This Script will drop the entire 'DataWarehouse' database if it exits
use with caution
*/
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
