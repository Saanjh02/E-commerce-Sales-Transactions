USE [E-commerce Sales Transactions];
GO

SELECT *
FROM INFORMATION_SCHEMA.TABLES;

--VIEW YOUR DATA

SELECT *
FROM ecommerce_sales;

--BASIC DATA UNDERSTANDING

--1.TOTAL ROWS
select count(*) as total_orders
from ecommerce_sales;

--2.TOTAL CUSTOMERS 
select count(distinct customer_id) as total_customer
from ecommerce_sales;

--3.TOTAL REVENUE
select sum(total_amount) as total_revenue
from ecommerce_sales;

--4.DATE RANGE
select min(order_date) as first_order,
       max(order_date) as last_order
from ecommerce_sales;

--CUSTOMER SEGMENTATION:
--1.Build Customer Summary:
select 
    customer_id,
	count(order_id) as total_orders,
	sum(total_amount) as total_spent,
  	avg(total_amount) as avg_total_value,
	sum(quantity) as total_quantity
from ecommerce_sales
group by customer_id;

--2.Create Customer Segments:

select *,
	case 
		when total_spent >= 5000 then 'premium'
		when total_spent >= 2000 then 'regular'
		else 'low value'
		end as customer_segment
 from 
     (
      select 
			customer_id,
			count(order_id) as total_orders,
			sum(total_amount) as total_spent,
  			avg(total_amount) as avg_total_value,
			sum(quantity) as total_quantity
	 from ecommerce_sales
     group by customer_id) s;

/*SEGMENT ANALYSIS:

1.Revenue by Segment:
This tells which segment brings money*/

SELECT
    customer_segment,
    COUNT(customer_id) AS total_customers,
    SUM(total_spent) AS total_revenue,
    AVG(total_spent) AS avg_spend_per_customer
FROM (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent,
        CASE 
            WHEN SUM(total_amount) >= 5000 THEN 'Premium'
            WHEN SUM(total_amount) >= 2000 THEN 'Regular'
            ELSE 'Low Value'
        END AS customer_segment
    FROM ecommerce_sales
    GROUP BY customer_id
) t
GROUP BY customer_segment
ORDER BY total_revenue DESC;

--2. Customer Distribution

SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM (
    SELECT
        customer_id,
        CASE 
            WHEN SUM(total_amount) >= 5000 THEN 'Premium'
            WHEN SUM(total_amount) >= 2000 THEN 'Regular'
            ELSE 'Low Value'
        END AS customer_segment
    FROM ecommerce_sales
    GROUP BY customer_id
) t
GROUP BY customer_segment;

--3. Average Order Value per Segment

SELECT
    customer_segment,
    AVG(total_spent) AS avg_customer_value
FROM (
    SELECT
        customer_id,
        SUM(total_amount) AS total_spent,
        CASE 
            WHEN SUM(total_amount) >= 5000 THEN 'Premium'
            WHEN SUM(total_amount) >= 2000 THEN 'Regular'
            ELSE 'Low Value'
        END AS customer_segment
    FROM ecommerce_sales
    GROUP BY customer_id
) t
GROUP BY customer_segment;

/*Top Customer Analysis
Who are the top 10 customers?
How much do they spend?
Do a few customers contribute a large portion of revenue?*/

SELECT TOP 10
    customer_id,
    COUNT(order_id) AS total_orders,
    SUM(total_amount) AS total_spent,
    AVG(total_amount) AS avg_order_value
FROM ecommerce_sales
GROUP BY customer_id
ORDER BY total_spent DESC;

/*Sales Trend Analysis
Which month had the highest revenue?
Are sales increasing or decreasing over time?
Is there seasonality?*/

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    SUM(total_amount) AS revenue
FROM ecommerce_sales
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    sales_year,
    sales_month;

/*Category Analysis
Which category generates the most revenue?
Which category sells the most units?*/

SELECT
    category,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue,
    SUM(quantity) AS units_sold
FROM ecommerce_sales
GROUP BY category
ORDER BY revenue DESC;

/*Regional Analysis
Which region is strongest?
Which region needs improvement?*/

SELECT
    region,
    SUM(total_amount) AS revenue,
    COUNT(order_id) AS total_orders
FROM ecommerce_sales
GROUP BY region
ORDER BY revenue DESC;

/*Return Analysis
What percentage of orders are returned?
Are returns affecting revenue significantly?*/

SELECT
    returned,
    COUNT(*) AS total_orders,
    SUM(total_amount) AS revenue
FROM ecommerce_sales
GROUP BY returned;