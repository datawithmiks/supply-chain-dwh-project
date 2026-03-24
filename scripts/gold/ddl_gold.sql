/* 
====================================================================================
DDL Script: Gold Layer Views
====================================================================================
Script Purpose:
  This script creates the Gold Layer views following a Star Schema
  design pattern. Views are built directly on top of silver.supply_chain
  with no additional storage required.

  Views Created:
    Dimensions:
    - gold.dim_customer
    - gold.dim_product
    - gold.dim_location
    - gold.dim_shipping
    - gold.dim_date
    Fact:
    - gold.fact_sales

Usage Example:
  Execute this script once to create all Gold Layer views.
====================================================================================
*/

-- ============================================================
-- Create Dimension: gold.dim_customer
-- ============================================================
CREATE OR ALTER VIEW gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER (ORDER BY customer_id)    AS customer_key,
    customer_id,
    customer_first_name,
    customer_last_name,
    customer_segment,
    customer_city,
    customer_state,
    customer_country,
    customer_street,
    customer_zipcode
FROM (
    SELECT DISTINCT
        customer_id,
        customer_first_name,
        customer_last_name,
        customer_segment,
        customer_city,
        customer_state,
        customer_country,
        customer_street,
        customer_zipcode
    FROM silver.supply_chain
) AS t;
GO

-- ============================================================
-- Create Dimension: gold.dim_product
-- ============================================================
CREATE OR ALTER VIEW gold.dim_product AS
SELECT
    ROW_NUMBER() OVER (ORDER BY product_card_id)    AS product_key,
    product_card_id,
    product_name,
    product_price,
    product_status,
    category_id,
    category_name,
    department_id,
    department_name
FROM (
    SELECT DISTINCT
        product_card_id,
        product_name,
        product_price,
        product_status,
        category_id,
        category_name,
        department_id,
        department_name
    FROM silver.supply_chain
) AS t;
GO
-- ============================================================
-- Create Dimension: gold.dim_location
-- ============================================================
CREATE OR ALTER VIEW gold.dim_location AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY market, order_region, order_country
    )                   AS location_key,
    market,
    order_region,
    order_country,
    order_state,
    order_city
FROM (
    SELECT DISTINCT
        market,
        order_region,
        order_country,
        order_state,
        order_city
    FROM silver.supply_chain
) AS t;
GO
-- ============================================================
-- Create Dimension: gold.dim_shipping
-- ============================================================
CREATE OR ALTER VIEW gold.dim_shipping AS
SELECT
    ROW_NUMBER() OVER (
        ORDER BY shipping_mode, delivery_status
    )                       AS shipping_key,
    shipping_mode,
    delivery_status,
    late_delivery_risk,
    days_shipping_real,
    days_shipping_scheduled
FROM (
    SELECT DISTINCT
        shipping_mode,
        delivery_status,
        late_delivery_risk,
        days_shipping_real,
        days_shipping_scheduled
    FROM silver.supply_chain
) AS t;
GO

-- ============================================================
-- Create Dimension: gold.dim_date
-- ============================================================
CREATE OR ALTER VIEW gold.dim_date AS
SELECT
    CAST(FORMAT(order_date, 'yyyyMMdd') AS INT)     AS date_key,
    order_date                                       AS full_date,
    DAY(order_date)                                  AS day_of_month,
    MONTH(order_date)                                AS month_number,
    DATENAME(MONTH, order_date)                      AS month_name,
    DATEPART(QUARTER, order_date)                    AS quarter_number,
    YEAR(order_date)                                 AS year_number,
    DATENAME(WEEKDAY, order_date)                    AS weekday_name,
    CASE
        WHEN DATENAME(WEEKDAY, order_date)
            IN ('Saturday', 'Sunday') THEN 'Yes'
        ELSE 'No'
    END AS is_weekend
FROM (
    SELECT DISTINCT order_date
    FROM silver.supply_chain
    WHERE order_date IS NOT NULL
) AS t;
GO
-- ============================================================
-- Create Fact: gold.fact_sales
-- ============================================================
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT
    -- Surrogate Keys (FK references to dimensions)
    dc.customer_key,
    dp.product_key,
    dl.location_key,
    ds.shipping_key,
    dd.date_key,

    -- Degenerate Dimensions
    sc.order_id,
    sc.order_item_id,
    sc.payment_type,
    sc.order_status,
    sc.ship_date,

    -- Measures
    sc.order_item_quantity,
    sc.order_item_discount,
    sc.order_item_discount_rate,
    sc.order_item_price,
    sc.order_item_total,
    sc.order_item_profit_ratio,
    sc.sales,
    sc.benefit_per_order,
    sc.sales_per_customer,
    sc.order_profit

FROM silver.supply_chain sc

LEFT JOIN gold.dim_customer dc
    ON sc.customer_id = dc.customer_id

LEFT JOIN gold.dim_product dp
    ON sc.product_card_id = dp.product_card_id

LEFT JOIN gold.dim_location dl
    ON  sc.market        = dl.market
    AND sc.order_region  = dl.order_region
    AND sc.order_country = dl.order_country
    AND sc.order_state   = dl.order_state
    AND sc.order_city    = dl.order_city

LEFT JOIN gold.dim_shipping ds
    ON  sc.shipping_mode    = ds.shipping_mode
    AND sc.delivery_status  = ds.delivery_status
    AND sc.days_shipping_real       = ds.days_shipping_real
    AND sc.days_shipping_scheduled  = ds.days_shipping_scheduled

LEFT JOIN gold.dim_date dd
    ON sc.order_date = dd.full_date;