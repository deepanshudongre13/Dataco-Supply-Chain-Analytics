create database dataco_supply_chain ;

use dataco_supply_chain ;

CREATE TABLE supply_chain_table (
    type TEXT,days_for_shipping_real INT,days_for_shipment_scheduled INT,benefit_per_order DOUBLE,sales_per_customer DOUBLE,delivery_status TEXT,late_delivery_risk INT,
    category_id TEXT,category_name TEXT,customer_city TEXT,customer_country TEXT,customer_fname TEXT,customer_id TEXT,customer_lname TEXT,customer_segment TEXT,
    customer_state TEXT,department_id TEXT,department_name TEXT,market TEXT,order_city TEXT,order_country TEXT,order_customer_id TEXT,order_date_dateorders DATETIME,
    order_id TEXT,order_item_cardprod_id TEXT,order_item_discount DOUBLE,order_item_discount_rate DOUBLE,order_item_id TEXT,order_item_product_price DOUBLE,
    order_item_profit_ratio INT,order_item_quantity INT,sales DOUBLE,order_item_total DOUBLE,order_profit_per_order DOUBLE,order_region TEXT,order_state TEXT,
    order_status TEXT,product_card_id TEXT,product_category_id TEXT,product_name TEXT,product_price DOUBLE,shipping_date_dateorders DATETIME,shipping_mode TEXT,
    delivery_delay_days INT,is_late_delivery INT,shipping_delay_vs_schedule INT,order_year INT,order_month INT,order_days_of_week TEXT,revenue_per_item DOUBLE,
    discount_flag INT,high_quantity_flag INT);
    
SET GLOBAL local_infile = 1;   
    
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dataco_supply_chain_cleaned.csv'
INTO TABLE supply_chain_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Q1: Get overall data overview (total records, unique orders, unique customers)

-- Data sanity check and sample preview

SELECT COUNT(*)
FROM supply_chain_table; 

SELECT *
FROM supply_chain_table
LIMIT 10;

SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers
FROM supply_chain_table;
       
       
-- Q2: Count late and on-time deliveries based on order level

SELECT 
    is_late_delivery, 
    COUNT(DISTINCT order_id) AS total_records
FROM supply_chain_table
GROUP BY is_late_delivery;


-- Q3: Analyze distribution of delivery status across all orders

SELECT 
    delivery_status, 
    COUNT(DISTINCT order_id) AS total_records
FROM supply_chain_table
GROUP BY delivery_status;


-- Q4: Calculate percentage of late deliveries out of total orders

SELECT 
    COUNT(DISTINCT order_id) * 100 /
    (SELECT COUNT(DISTINCT order_id)
	 FROM supply_chain_table) AS late_delivery_percent
FROM supply_chain_table
WHERE is_late_delivery = 1;


-- Q5: Calculate average delivery delay (in days) for late deliveries

SELECT 
    is_late_delivery,
    AVG(delivery_delay_days) AS avg_delivery_days
FROM supply_chain_table
WHERE is_late_delivery = 1; 


-- Q6: Identify shipping modes with the highest number of late deliveries in percentage (order level)

SELECT 
    shipping_mode,
    (COUNT(DISTINCT order_id)) * 100 / 
    (SELECT COUNT(DISTINCT order_id)
	 FROM supply_chain_table) AS late_delivery_percent
FROM supply_chain_table
WHERE is_late_delivery = 1
GROUP BY shipping_mode
ORDER BY late_delivery_percent DESC; 


-- Q7: Analyze month-wise trend of late deliveries (order level)

SELECT 
    order_month, 
    COUNT(DISTINCT order_id) AS total_records
FROM supply_chain_table
WHERE is_late_delivery = 1
GROUP BY order_month
order by order_month; 


-- Q8: Identify regions with the highest late delivery percentage

SELECT
    order_region,
    COUNT(DISTINCT CASE WHEN is_late_delivery = 1 THEN order_id END) * 100.0
    / COUNT(DISTINCT order_id) AS late_delivery_percentage
FROM supply_chain_table
GROUP BY order_region
ORDER BY late_delivery_percentage DESC;


-- Q9: Analyze whether discounted orders have a higher late delivery percentage


SELECT 
    discount_flag, 
    COUNT(DISTINCT case when is_late_delivery = 1 then order_id end) * 100.0 / 
    count(distinct order_id) as late_delivery_percentage
FROM supply_chain_table
GROUP BY discount_flag; 


-- Q10: Analyze whether high-quantity orders have a higher late delivery percentage


SELECT 
    high_quantity_flag,
    COUNT(DISTINCT case when is_late_delivery = 1 then order_id end) * 100.0 / 
    count(distinct order_id) as late_delivery_percentage
FROM supply_chain_table
GROUP BY high_quantity_flag ; 

-----------------------------------------------------------------------------------------------------------------------------------------------------------------

/* =========================================================
   VIEW NAME: analytics_view
   PURPOSE  : Analytics-ready view for Supply Chain Analysis
   GRAIN    : One row = One Order Item
   SOURCE   : supply_chain_table (cleaned via Python)
   USED FOR : Power BI Dashboard & Business Insights
   ========================================================= */

CREATE OR REPLACE VIEW analytics_view AS
SELECT

-- ORDER DETAILS (Header Level)
    order_id,
    order_item_id,
    order_customer_id,
    order_status,

    order_date_dateorders,
    order_year,
    order_month,
    order_days_of_week,

    order_city,
    order_state,
    order_country,
    order_region,

-- CUSTOMER INFORMATION       
    customer_id,
    customer_segment,

-- PRODUCT INFORMATION
    product_card_id,
    product_name,
    category_name,
    product_price,

-- SHIPPING & LOGISTICS DETAILS
    shipping_mode,
    days_for_shipping_real,
    days_for_shipment_scheduled,
    delivery_delay_days,

-- ORDER ITEM METRICS (FACT DATA)
    order_item_quantity,
    order_item_discount_rate,
    sales,
    order_item_total,
    order_profit_per_order,

-- DELIVERY DELAY BUCKET
-- Purpose: Categorize delivery delay
    CASE
        WHEN delivery_delay_days = 0 THEN 'On Time'
        WHEN delivery_delay_days BETWEEN 1 AND 2 THEN 'Slight Delay'
        WHEN delivery_delay_days BETWEEN 3 AND 5 THEN 'Moderate Delay'
        WHEN delivery_delay_days BETWEEN 6 AND 10 THEN 'High Delay'
        ELSE 'Severe Delay'
    END AS delay_bucket,

-- DISCOUNT BUCKET
-- Purpose: Analyze impact of discounts

    CASE
        WHEN order_item_discount_rate = 0 THEN 'No Discount'
        WHEN order_item_discount_rate > 0
             AND order_item_discount_rate <= 0.10 THEN 'Low Discount'
        WHEN order_item_discount_rate > 0.10
             AND order_item_discount_rate <= 0.20 THEN 'Medium Discount'
        WHEN order_item_discount_rate > 0.20
             AND order_item_discount_rate <= 0.40 THEN 'High Discount'
        ELSE 'Very High Discount'
    END AS discount_bucket,

-- QUANTITY BUCKET
-- Purpose: Identify bulk vs small orders

    CASE
        WHEN order_item_quantity BETWEEN 1 AND 2 THEN 'Low'
        WHEN order_item_quantity BETWEEN 3 AND 5 THEN 'Medium'
        WHEN order_item_quantity BETWEEN 6 AND 10 THEN 'High'
        ELSE 'Bulk'
    END AS quantity_bucket
    
FROM supply_chain_table ;


select * 
from analytics_view ; 


