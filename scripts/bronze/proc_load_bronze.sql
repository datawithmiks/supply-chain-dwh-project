/*
==============================================================================
Stored Procedure: bronze.load_bronze
==============================================================================
Script Purpose:
    This stored procedure performs the full load of raw data
    into the 'bronze.supply_chain_raw' table from the DataCo
    Supply Chain CSV source file. It includes:
    - Truncating the existing Bronze table before loading.
    - Bulk inserting all rows from the source CSV file.
    - Logging the start time, end time and total load duration.
    - Error handling to catch and display any load failures.

Parameters:
    None

Usage:
    EXEC bronze.load_bronze;

Notes:
    - Run this procedure after the Bronze DDL script.
    - Source file must exist at the specified file path.
    - No transformations applied — raw data loaded as-is.
    - Load strategy: Full Load (Truncate and Insert).
==============================================================================
*/


CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	BEGIN TRY
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
	SET @batch_start_time = GETDATE();
	PRINT 'Loading Bronze Layer';
	PRINT '===================================';

	PRINT '>> Truncating Table: bronze.supply_chain_raw';
	TRUNCATE TABLE bronze.supply_chain_raw;
	PRINT '>> Inserting Data Into: bronze.supply_chain_raw';
	BULK INSERT bronze.supply_chain_raw
	FROM 'C:\\supply_chain_dwh_project\\datasets\\DataCoSupplyChainDataset.csv'
	WITH (
		FIRSTROW			= 2,
		FIELDTERMINATOR		= ',',
		ROWTERMINATOR		= '0x0a',
		TABLOCK				
	);
	SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Bronze Layer is Completed' 
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
		PRINT '=========================================='
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	END CATCH
END
GO

-- ============================================
-- Execute the Stored Procedure
-- ============================================
EXEC bronze.load_bronze;

