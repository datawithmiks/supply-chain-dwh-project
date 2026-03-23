-- Data Quality checks

-- Checking columns are NULL
-- Expectation: No result
SELECT [Order Id],
        [Customer Id],
        [Order Customer Id],
        [Product Name],
        [Sales],
        [Order Item Quantity],
        [order date (DateOrders)],
        [shipping date (DateOrders)]
FROM bronze.supply_chain_raw
WHERE [Order Id] IS NULL
   OR [Customer Id] IS NULL
   OR [Order Customer Id] IS NULL
   OR [Product Name] IS NULL
   OR [Sales] IS NULL
   OR [Order Item Quantity] IS NULL
   OR [order date (DateOrders)] IS NULL
   OR [shipping date (DateOrders)] IS NULL;

-- Shipping date should not be earlier than order date
-- Expectation: No result
SELECT [order date (DateOrders)],
        [shipping date (DateOrders)]
FROM bronze.supply_chain_raw
WHERE [shipping date (DateOrders)] < [order date (DateOrders)];

-- Sales, quantity, and price should not be negative
-- Expectation: No result 
SELECT * 
FROM bronze.supply_chain_raw
WHERE [Sales] < 0
   OR [Order Item Quantity] <= 0
   OR [Product Price] < 0
   OR [Order Item Product Price] < 0;

-- Duplicate Order Item records
-- Expectation: No result 
SELECT [Order Id], 
        [Order Item Id], 
        COUNT(*) AS duplicate_count
FROM bronze.supply_chain_raw
GROUP BY [Order Id], [Order Item Id]
HAVING COUNT(*) > 1;

-- Blank strings on key name fields
-- Expectation: No result 
SELECT * 
FROM bronze.supply_chain_raw
WHERE LTRIM(RTRIM([Customer Fname])) = ''
   OR LTRIM(RTRIM([Customer Lname])) = ''
   OR LTRIM(RTRIM([Product Name])) = ''
   OR LTRIM(RTRIM([Delivery Status])) = ''
   OR LTRIM(RTRIM([Order Status])) = '';

-- Customer Id vs Order Customer Id should match
-- Expectation: No result 
SELECT * 
FROM bronze.supply_chain_raw
WHERE [Customer Id] <> [Order Customer Id];

-- Category Id vs Product Category Id should match
-- Expectation: No result 
SELECT * FROM bronze.supply_chain_raw
WHERE [Category Id] <> [Product Category Id];

-- Check for unexpected Delivery Status values
SELECT DISTINCT [Delivery Status] 
FROM bronze.supply_chain_raw;

-- Check for unexpected Shipping Mode values
SELECT DISTINCT [Shipping Mode] 
FROM bronze.supply_chain_raw;

-- Check for unexpected Customer Segment values
SELECT DISTINCT [Customer Segment] 
FROM bronze.supply_chain_raw;

-- Check for unexpected Market values
SELECT DISTINCT [Market] 
FROM bronze.supply_chain_raw;

-- Flag rows where Product Status is not in expected domain
-- No Expectation: No result
SELECT * FROM bronze.supply_chain_raw
WHERE [Product Status] NOT IN (0, 1);

-- Check unwanted leading/trailing spaces across all key string columns
-- Expectation: No result
SELECT *
FROM bronze.supply_chain_raw
WHERE [Type]             != LTRIM(RTRIM([Type]))
   OR [Delivery Status]  != LTRIM(RTRIM([Delivery Status]))
   OR [Order Status]     != LTRIM(RTRIM([Order Status]))
   OR [Shipping Mode]    != LTRIM(RTRIM([Shipping Mode]))
   OR [Customer Fname]   != LTRIM(RTRIM([Customer Fname]))
   OR [Customer Lname]   != LTRIM(RTRIM([Customer Lname]))
   OR [Customer City]    != LTRIM(RTRIM([Customer City]))
   OR [Customer Country] != LTRIM(RTRIM([Customer Country]))
   OR [Customer Segment] != LTRIM(RTRIM([Customer Segment]))
   OR [Product Name]     != LTRIM(RTRIM([Product Name]))
   OR [Market]           != LTRIM(RTRIM([Market]))
   OR [Order City]       != LTRIM(RTRIM([Order City]))
   OR [Order Country]    != LTRIM(RTRIM([Order Country]))
   OR [Order Region]     != LTRIM(RTRIM([Order Region]))
   OR [Department Name]  != LTRIM(RTRIM([Department Name]))
   OR [Category Name]    != LTRIM(RTRIM([Category Name]));

-- Latitude must be between -90 and 90
-- Longitude must be between -180 and 180
-- Expectation: No result
SELECT * FROM bronze.supply_chain_raw
WHERE [Latitude] NOT BETWEEN -90 AND 90
   OR [Longitude] NOT BETWEEN -180 AND 180;

-- Shipping Days
SELECT
         [Days for shipping (real)],
         [Days for shipment (scheduled)]
FROM bronze.supply_chain_raw
WHERE ([Days for shipping (real)] < 0 
        OR [Days for shipping (real)] IS NULL) OR
      ([Days for shipment (scheduled)] < 0 
        OR [Days for shipment (scheduled)] IS NULL);

-- Financial
-- Checks Null values
SELECT [Benefit per order],
        [Sales per customer]
FROM bronze.supply_chain_raw
WHERE [Benefit per order] IS NULL 
    OR  [Sales per customer] IS NULL;

-- Data Standardization
SELECT [Late_delivery_risk],
        [Product Status],
        CASE WHEN [Late_delivery_risk] = 1 THEN 'Yes'
             WHEN [Late_delivery_risk] = 0 THEN 'No'
             ELSE 'Unknown'
        END AS late_delivery_risk,

        CASE WHEN [Product Status] = 1 THEN 'Active'
             WHEN [Product Status] = 0 THEN 'Inactive'
             ELSE 'Unknown'
        END AS product_status
FROM bronze.supply_chain_raw

--Usage Example:
  EXEC silver.load_silver;