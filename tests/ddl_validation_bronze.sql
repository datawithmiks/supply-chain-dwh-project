/*
==============================================================================
DDL Validation — Bronze Layer
==============================================================================
Script Purpose:
    This script validates the table structure of the
    'bronze.supply_chain_raw' table after creation. 
    It includes checks for:
    - Table existence in the bronze schema.
    - Column count validation (expected: 53 columns).
    - Column names and data types verification.

Usage Notes:
    - Run this script after executing the Bronze DDL script.
    - No data is checked here — structure validation only.
    - Expected result: 53 columns matching the source CSV.
    - If column count is incorrect, re-run the DDL script.
==============================================================================
*/


-- Check table exists
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
	AND TABLE_NAME = 'supply_chain_raw';

-- Check all 53 columns
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
	AND TABLE_NAME = 'supply_chain_raw'
ORDER BY ORDINAL_POSITION;
-- Expected: 53 columns ✅