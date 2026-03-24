/*
==============================================================================
Quality Checks: Gold Layer — dim and fact views
==============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'gold' schema views. It includes checks for:
    - Surrogate key uniqueness across all dimension views.
    - NULL surrogate keys in the fact view.
    - Referential integrity between fact and dimension views.
    - Row count consistency between silver and gold layers.
    - Fan-out diagnostic tests per dimension join.
    - Duplicate detection in composite key dimensions.
    - Date dimension format and range validation.
    - Domain value checks on standardized columns.
    - NULL measures in the fact view.

Usage Notes:
    - Run these checks after executing the Gold Layer DDL views script.
    - Expectation is noted on each check — queries returning results
      indicate a potential data quality issue.
    - If row counts do not match between silver and gold, run the
      individual join diagnostic tests to isolate the culprit dimension.
==============================================================================
*/

-- gold.dim_customer
-- Expectation: No result
SELECT customer_key,
		COUNT(*) AS duplicate_count
FROM gold.dim_customer
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- gold.dim_product
-- Expectation: No result
SELECT product_key,
		COUNT(*) AS duplicate_count
FROM gold.dim_product
GROUP BY product_key
HAVING COUNT(*) > 1;

-- gold.dim_shipping
-- Expectation: No result
SELECT shipping_key,
		COUNT(*) AS duplicate_key
FROM gold.dim_shipping
GROUP BY shipping_key
HAVING COUNT(*) > 1;

-- gold.location
-- Expectation: No result
SELECT location_key,
		COUNT(*) AS duplicate_key
FROM gold.dim_location
GROUP BY location_key
HAVING COUNT(*) > 1;

-- gold.dim_date
-- Expectation: No result
SELECT date_key,
		COUNT(*) AS duplicate_key
FROM gold.dim_date
GROUP BY date_key
HAVING COUNT(*) > 1;

-- NULL Surrogate Key Check in Fact Table
-- Expectation: No result
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL
	OR product_key IS NULL
	OR shipping_key IS NULL
	OR location_key IS NULL
	OR date_key IS NULL;

-- Referential Integrity Check
-- customer_key orphan check
-- Expectation: No result
SELECT fs.customer_key
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customer dc
ON fs.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- product_key orphan check
-- Expectation: No result
SELECT fs.product_key
FROM gold.fact_sales fs
LEFT JOIN gold.dim_product dp
ON fs.product_key = dp.product_key
WHERE dp.product_key IS NULL;

-- location_key  orphan check
-- Expectation: No result
SELECT fs.location_key
FROM gold.fact_sales fs
LEFT JOIN gold.dim_location dl
ON fs.location_key = dl.location_key
WHERE dl.location_key IS NULL;

-- shipping_key   orphan check
-- Expectation: No result
SELECT fs.shipping_key
FROM gold.fact_sales fs
LEFT JOIN gold.dim_shipping ds
ON fs.shipping_key = ds.shipping_key
WHERE ds.shipping_key IS NULL;

-- date_key  orphan check
-- Expectation: No result
SELECT fs.date_key
FROM gold.fact_sales fs
LEFT JOIN gold.dim_date dd
ON fs.date_key = dd.date_key
WHERE dd.date_key IS NULL;

-- Expectation: Both counts should match
SELECT 'silver.supply_chain' AS source, 
		COUNT(*) AS row_count
FROM silver.supply_chain
UNION ALL
SELECT 'gold.fact_sales',       
		COUNT(*)
FROM gold.fact_sales;
-- If the expectation above this line not match
-- Test 1: Only dim_customer join
-- Expectation: 180,519
SELECT COUNT(*)
FROM silver.supply_chain sc
LEFT JOIN gold.dim_customer dc
    ON sc.customer_id = dc.customer_id;

-- Test 2: Only dim_product join
-- Expectation: 180,519 
-- This is the culprit
SELECT COUNT(*)
FROM silver.supply_chain sc
LEFT JOIN gold.dim_product dp
    ON sc.product_card_id = dp.product_card_id;

-- Test 3: Only dim_location join
-- Expectation: 180,519
SELECT COUNT(*)
FROM silver.supply_chain sc
LEFT JOIN gold.dim_location dl
    ON  sc.market        = dl.market
    AND sc.order_region  = dl.order_region
    AND sc.order_country = dl.order_country
    AND sc.order_state   = dl.order_state
    AND sc.order_city    = dl.order_city;

-- Test 4: Only dim_shipping join
-- Expectation: 180,519
SELECT COUNT(*)
FROM silver.supply_chain sc
LEFT JOIN gold.dim_shipping ds
    ON  sc.shipping_mode           = ds.shipping_mode
    AND sc.delivery_status         = ds.delivery_status
    AND sc.days_shipping_real      = ds.days_shipping_real
    AND sc.days_shipping_scheduled = ds.days_shipping_scheduled;

-- Test 5: Only dim_date join
-- Expectation: 180,519
SELECT COUNT(*)
FROM silver.supply_chain sc
LEFT JOIN gold.dim_date dd
    ON sc.order_date = dd.full_date;

-- Check what is causing duplicates in dim_location
-- Expectation: No result
SELECT market, order_region, order_country,
       order_state, order_city,
       COUNT(*) AS duplicate_count
FROM gold.dim_location
GROUP BY market, order_region, order_country,
         order_state, order_city
HAVING COUNT(*) > 1;

-- Check if dim_shipping is truly unique
-- Expectation: No result
SELECT shipping_mode, delivery_status,
       days_shipping_real, days_shipping_scheduled,
       COUNT(*) AS duplicate_count
FROM gold.dim_shipping
GROUP BY shipping_mode, delivery_status,
         days_shipping_real, days_shipping_scheduled
HAVING COUNT(*) > 1;

-- dim date checks
-- date_key format should always be 8 digits (yyyyMMdd)
-- Expectation: No result
SELECT date_key
FROM gold.dim_date
WHERE LEN(CAST(date_key AS VARCHAR)) != 8;

-- quarter_number should only be 1 to 4
-- Expectation: No result
SELECT quarter_number
FROM gold.dim_date
WHERE quarter_number NOT BETWEEN 1 AND 4;

-- month_number should only be 1 to 12
-- Expectation: No result
SELECT month_number
FROM gold.dim_date
WHERE month_number NOT BETWEEN 1 AND 12;

-- is_weekend should only be Yes or No
-- Expectation: No result
SELECT DISTINCT is_weekend
FROM gold.dim_date
WHERE is_weekend NOT IN ('Yes', 'No');

-- product_status should only be Active or Inactive
-- Expectation: No result
SELECT DISTINCT product_status
FROM gold.dim_product
WHERE product_status NOT IN ('Active', 'Inactive');

-- late_delivery_risk should only be Yes or No
-- Expectation: No result
SELECT DISTINCT late_delivery_risk
FROM gold.dim_shipping
WHERE late_delivery_risk NOT IN ('Yes', 'No');

-- Measure NULL check in Fact
-- Expectation: No result
SELECT *
FROM gold.fact_sales
WHERE order_item_quantity    IS NULL
   OR sales                  IS NULL
   OR order_profit           IS NULL
   OR benefit_per_order      IS NULL
   OR order_item_total       IS NULL;