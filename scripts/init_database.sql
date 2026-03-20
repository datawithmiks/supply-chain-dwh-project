/*
==========================================================================
Create Database and Schemas
==========================================================================
Script Purpose:
  This script creates a new database named 'SupplyChainDWH' after checking if it already exists.
  If the database exists, it is dropped and recreated. 
  Additionally, the script sets up three schemas within the database: 
  'bronze', 'silver', and 'gold'.

WARNING:
  Running this script will drop the entire 'SupplyChainDWH' database if it exists.
  All data in the database will be permanently deleted. 
  Proceed with caution and ensure you have proper backups before running this script.
*/

-- Go to system database
USE master
GO
-- Drop and recreate the 'SupplyChainDWH' database
IF EXISTS (SELECT 1 
		   FROM sys.databases 
		   WHERE name = 'SupplyChainDWH')
BEGIN
	ALTER DATABASE SupplyChainDWH SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE SupplyChainDWH ;
END;
GO
-- Create new database 'SupplyChainDWH'
CREATE DATABASE SupplyChainDWH
GO 
-- Switch into NEW database
USE SupplyChainDWH
GO
-- Create Medallion architecture
CREATE SCHEMA bronze;
GO 
CREATE SCHEMA silver;
GO 
CREATE SCHEMA gold;
GO
