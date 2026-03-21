/*
==============================================================================
DDL Script — Silver Layer
==============================================================================
Script Purpose:
    This script creates the cleaned table in the 'silver' schema
    for the DataCo Supply Chain Data Warehouse. It includes:
    - Dropping the existing table if it already exists.
    - Creating the table with 48 columns mapped from Bronze.
    - Renamed columns following snake_case naming convention.
    - Excluded columns that have no analytical value.

Excluded Columns (5):
    - [Customer Email]       → masked as XXXXXXXXX
    - [Customer Password]    → masked as XXXXXXXXX
    - [Product Description]  → mostly empty
    - [Product Image]        → URL only, no analytical value
    - [Category Id]          → duplicate of [Product Category Id]

Usage Notes:
    - Run this script before executing the Silver load procedure.
    - No data is inserted here — table structure only.
    - Column names follow snake_case naming convention.
    - Data types upgraded from VARCHAR to NVARCHAR for
      international character support.
==============================================================================
*/


-- Check if the table is exits then drop once exists
IF OBJECT_ID('silver.supply_chain', 'U') IS NOT NULL
    DROP TABLE silver.supply_chain;
GO

CREATE TABLE silver.supply_chain (

    -- Payment
    payment_type                NVARCHAR(50),       -- [Type]

    -- Shipping Days
    days_shipping_real          INT,                -- [Days for shipping (real)]
    days_shipping_scheduled     INT,                -- [Days for shipment (scheduled)]

    -- Financial
    benefit_per_order           DECIMAL(18,2),      -- [Benefit per order]
    sales_per_customer          DECIMAL(18,2),      -- [Sales per customer]

    -- Delivery
    delivery_status             NVARCHAR(50),       -- [Delivery Status]
    late_delivery_risk          NVARCHAR(10),       -- [Late_delivery_risk] → 0/1 to Yes/No

    -- Category
    category_id                 INT,                -- [Category Id]
    category_name               NVARCHAR(100),      -- [Category Name]

    -- Customer
    customer_city               NVARCHAR(100),      -- [Customer City]
    customer_country            NVARCHAR(100),      -- [Customer Country]
    customer_first_name         NVARCHAR(100),      -- [Customer Fname]
    customer_id                 INT,                -- [Customer Id]
    customer_last_name          NVARCHAR(100),      -- [Customer Lname]
    -- EXCLUDED: customer_email    → [Customer Email]    masked as XXXXXXXXX
    -- EXCLUDED: customer_password → [Customer Password] masked as XXXXXXXXX
    customer_segment            NVARCHAR(50),       -- [Customer Segment]
    customer_state              NVARCHAR(100),      -- [Customer State]
    customer_street             NVARCHAR(200),      -- [Customer Street]
    customer_zipcode            NVARCHAR(20),       -- [Customer Zipcode]

    -- Department
    department_id               INT,                -- [Department Id]
    department_name             NVARCHAR(100),      -- [Department Name]

    -- Location
    latitude                    DECIMAL(18,8),      -- [Latitude]
    longitude                   DECIMAL(18,8),      -- [Longitude]
    market                      NVARCHAR(100),      -- [Market]

    -- Order Location
    order_city                  NVARCHAR(100),      -- [Order City]
    order_country               NVARCHAR(100),      -- [Order Country]
    order_customer_id           INT,                -- [Order Customer Id]

    -- Order Details
    order_date                  DATE,               -- [order date (DateOrders)]
    order_id                    INT,                -- [Order Id]
    product_card_id             INT,                -- [Order Item Cardprod Id]
    order_item_discount         DECIMAL(18,2),      -- [Order Item Discount]
    order_item_discount_rate    DECIMAL(18,4),      -- [Order Item Discount Rate]
    order_item_id               INT,                -- [Order Item Id]
    order_item_price            DECIMAL(18,2),      -- [Order Item Product Price]
    order_item_profit_ratio     DECIMAL(18,4),      -- [Order Item Profit Ratio]
    order_item_quantity         INT,                -- [Order Item Quantity]
    sales                       DECIMAL(18,2),      -- [Sales]
    order_item_total            DECIMAL(18,2),      -- [Order Item Total]
    order_profit                DECIMAL(18,2),      -- [Order Profit Per Order]

    -- Order Location Details
    order_region                NVARCHAR(100),      -- [Order Region]
    order_state                 NVARCHAR(100),      -- [Order State]
    order_status                NVARCHAR(50),       -- [Order Status]
    order_zipcode               NVARCHAR(20),       -- [Order Zipcode]

    -- Product
    -- EXCLUDED: category_id_dup   → [Category Id]      duplicate of product_category_id
    product_category_id         INT,                -- [Product Category Id]
    -- EXCLUDED: product_desc      → [Product Description]  mostly empty
    -- EXCLUDED: product_image     → [Product Image]        URL only
    product_name                NVARCHAR(200),      -- [Product Name]
    product_price               DECIMAL(18,2),      -- [Product Price]
    product_status              NVARCHAR(20),       -- [Product Status] → 0/1 to Active/Inactive

    -- Shipping
    ship_date                   DATE,               -- [shipping date (DateOrders)]
    shipping_mode               NVARCHAR(50),       -- [Shipping Mode]

    -- Metadata (system generated)
    dwh_create_date             DATETIME2 DEFAULT GETDATE()  -- system generated → GETDATE()
);
GO
