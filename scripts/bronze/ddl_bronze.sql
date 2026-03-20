/* 
=============================================================================
DDL Script: Create Bronze Tables
=============================================================================
This script creates the raw table in the 'bronze' schema
    for the DataCo Supply Chain Data Warehouse. It includes:
    - Dropping the existing table if it already exists.
    - Creating the table with all 53 columns matching
      the source CSV file structure.

Usage Notes:
    - Run this script before executing the BULK INSERT script.
    - No data is inserted in this script — table structure only.
    - Column names and data types match the source CSV as-is.
    - No transformations or cleaning is applied at this stage.
=============================================================================
*/

-- Check if the table is exits then drop once exists
IF OBJECT_ID ('bronze.supply_chain_raw', 'U') IS NOT NULL
	DROP TABLE bronze.supply_chain_raw;
GO

CREATE TABLE bronze.supply_chain_raw (
	-- payment & shipping days
	 [Type]								VARCHAR(50),
	 [Days for shipping (real)]			INT,
	 [Days for shipment (scheduled)]	INT,
	-- financial
	[Benefit per order]					DECIMAL(18,2),
	[Sales per customer]				DECIMAL(18,2),
	-- delivery
	[Delivery Status]					VARCHAR(50),
	[Late_delivery_risk]				INT,
	-- category
	[Category Id]						INT,
	[Category Name]						VARCHAR(50),
	-- customer
	[Customer City]						NVARCHAR(50),
	[Customer Country]					NVARCHAR(50),
	[Customer Email]					VARCHAR(50),
	[Customer Fname]					VARCHAR(50),
	[Customer Id]						INT,
	[Customer Lname]					VARCHAR(50),
	[Customer Password]					VARCHAR(50),
	[Customer Segment]					VARCHAR(50),
	[Customer State]					VARCHAR(50),
	[Customer Street]					VARCHAR(50),
	[Customer Zipcode]					VARCHAR(20),
	-- department
	[Department Id]						INT,
	[Department Name]					VARCHAR(50),
	-- location
	[Latitude]							DECIMAL(18,2),
	[Longitude]							DECIMAL(18,2),
	[Market]							VARCHAR(50),
	-- order location
	[Order City]						NVARCHAR(50),
	[Order Country]						NVARCHAR(50),
	[Order Customer Id]					INT,
	-- order details
	[order date (DateOrders)]           DATETIME,			
    [Order Id]                          INT,              
    [Order Item Cardprod Id]            INT,             
    [Order Item Discount]               DECIMAL(18,2),    
    [Order Item Discount Rate]          DECIMAL(18,4),    
    [Order Item Id]                     INT,             
    [Order Item Product Price]          DECIMAL(18,2),    
    [Order Item Profit Ratio]           DECIMAL(18,4),    
    [Order Item Quantity]               INT,              
    [Sales]                             DECIMAL(18,2),   
    [Order Item Total]                  DECIMAL(18,2),    
    [Order Profit Per Order]			DECIMAL(18,2), 
	-- order location details
	[Order Region]                      VARCHAR(50),    
    [Order State]                       NVARCHAR(50),    
    [Order Status]                      VARCHAR(50),      
    [Order Zipcode]                     VARCHAR(20),    
	-- product
	[Product Card Id]                   INT,            
    [Product Category Id]               INT,            
    [Product Description]               VARCHAR(MAX),    
    [Product Image]                     VARCHAR(MAX),     
    [Product Name]                      VARCHAR(200),   
    [Product Price]                     DECIMAL(18,2),   
    [Product Status]                    INT,     
	-- shipping
	[shipping date (DateOrders)]        DATETIME,       
    [Shipping Mode]                     VARCHAR(50)     
);