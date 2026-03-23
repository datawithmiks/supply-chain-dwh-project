/* 
====================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
====================================================================================
Script Purpose:
  This stored procedure performs the ETL (Extract, Transform, Load) process to 
  populate the 'silver' schema tables from the 'bronze' schema.

  Actions Performed:
    - Truncates Silver Tables.
    - Inserts transformed and cleansed data from Bronze into Silver tables.
    - Applies TRIM() on all string columns to remove unwanted leading/trailing spaces.
    - Applies CASE transformation on [Late_delivery_risk]  → 'Yes' / 'No'.
    - Applies CASE transformation on [Product Status]      → 'Active' / 'Inactive'.

Parameters:
  None.
  This stored procedure does not accept any parameters or return any values.

Usage Example:
  EXEC silver.load_silver;
====================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN 
	BEGIN TRY
	DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;
		SET @batch_start_time = GETDATE();

		PRINT 'Loading Silver Layer';
		PRINT '===================================';
		PRINT '>> Truncating Table: silver.supply_chain';
		TRUNCATE TABLE silver.supply_chain;

		PRINT '>> Inserting Data Info: silver.supply_chain';
		INSERT INTO silver.supply_chain (
		    payment_type,               -- [Type]

            -- Shipping Days
            days_shipping_real,         -- [Days for shipping (real)]
            days_shipping_scheduled,    -- [Days for shipment (scheduled)]

            -- Financial
            benefit_per_order,          -- [Benefit per order]
            sales_per_customer,         -- [Sales per customer]

            -- Delivery
            delivery_status,            -- [Delivery Status]
            late_delivery_risk,         -- [Late_delivery_risk] → 0/1 to Yes/No

            -- Category
            category_id,                -- [Category Id]
            category_name,              -- [Category Name]

            -- Customer
            customer_city,              -- [Customer City]
            customer_country,           -- [Customer Country]
            customer_first_name,        -- [Customer Fname]
            customer_id,                -- [Customer Id]
            customer_last_name,         -- [Customer Lname]
            customer_segment,           -- [Customer Segment]
            customer_state,             -- [Customer State]
            customer_street,            -- [Customer Street]
            customer_zipcode,           -- [Customer Zipcode]

            -- Department
            department_id,             -- [Department Id]
            department_name,           -- [Department Name]

            -- Location
            latitude,                  -- [Latitude]
            longitude,                 -- [Longitude]
            market,                    -- [Market]

            -- Order Location
            order_city,                -- [Order City]
            order_country,             -- [Order Country]
            order_customer_id,         -- [Order Customer Id]

            -- Order Details
            order_date,                -- [order date (DateOrders)]
            order_id,                  -- [Order Id]
            product_card_id,           -- [Order Item Cardprod Id]
            order_item_discount,       -- [Order Item Discount]
            order_item_discount_rate,  -- [Order Item Discount Rate]
            order_item_id,             -- [Order Item Id]
            order_item_price,          -- [Order Item Product Price]
            order_item_profit_ratio,   -- [Order Item Profit Ratio]
            order_item_quantity,       -- [Order Item Quantity]
            sales,                     -- [Sales]
            order_item_total,          -- [Order Item Total]
            order_profit,              -- [Order Profit Per Order]

            -- Order Location Details
            order_region,              -- [Order Region]
            order_state,               -- [Order State]
            order_status,              -- [Order Status]
            order_zipcode,             -- [Order Zipcode]
            product_category_id,       -- [Product Category Id]
            product_name,              -- [Product Name]
            product_price,             -- [Product Price]
            product_status,            -- [Product Status] → 0/1 to Active/Inactive

            -- Shipping
            ship_date,                 -- [shipping date (DateOrders)]
            shipping_mode              -- [Shipping Mode]
            )

        SELECT
            TRIM([Type]),
            [Days for shipping (real)],
            [Days for shipment (scheduled)],
            [Benefit per order],
            [Sales per customer],
            TRIM([Delivery Status]),
            CASE WHEN [Late_delivery_risk] = 1 THEN 'Yes'
                 WHEN [Late_delivery_risk] = 0 THEN 'No'
                 ELSE 'n/a' 
            END AS [Late_delivery_risk],
            [Category Id],
            TRIM([Category Name]),
            TRIM([Customer City]),
            TRIM([Customer Country]),
            TRIM([Customer Fname]),
            [Customer Id],
            TRIM([Customer Lname]),
            TRIM([Customer Segment]),
            TRIM([Customer State]),
            TRIM([Customer Street]),
            [Customer Zipcode],
            [Department Id],
            TRIM([Department Name]),
            [Latitude],
            [Longitude],
            TRIM([Market]),
            TRIM([Order City]),
            TRIM([Order Country]),
            [Order Customer Id],
            [order date (DateOrders)],
            [Order Id],
            [Order Item Cardprod Id],
            [Order Item Discount],
            [Order Item Discount Rate],
            [Order Item Id],
            [Order Item Product Price],
            [Order Item Profit Ratio],
            [Order Item Quantity],
            [Sales],
            [Order Item Total],
            [Order Profit Per Order],
            TRIM([Order Region]),
            TRIM([Order State]),
            TRIM([Order Status]),
            [Order Zipcode],
            [Product Category Id],
            TRIM([Product Name]),
            [Product Price],
            CASE WHEN [Product Status] = 1 THEN 'Active'
                 WHEN [Product Status] = 0 THEN 'Inactive'
                 ELSE 'n/a' 
            END AS [Product Status],
            [shipping date (DateOrders)],
            TRIM([Shipping Mode])
        FROM bronze.supply_chain_raw;

		SET @batch_end_time = GETDATE();
		PRINT '=========================================='
		PRINT 'Loading Silver Layer is Completed' 
		PRINT ' - Total Load Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR(50)) + ' seconds';
		PRINT '=========================================='
  
  END TRY
        BEGIN CATCH
		PRINT '==========================================';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: '  + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: '   + CAST(ERROR_STATE() AS NVARCHAR);
		PRINT '==========================================';
	    END CATCH
END
