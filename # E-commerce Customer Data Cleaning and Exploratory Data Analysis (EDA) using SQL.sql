

## E-commerce Customer Data Cleaning and Exploratory Data Analysis (EDA) using SQL

/* =====================================================
   1. DATA OVERVIEW
===================================================== */

-- View complete customer dataset
USE e_commerce;
SELECT * 
FROM e_commerce.customer_details;

-- Display first 10 records
SELECT *
FROM e_commerce.customer_details
LIMIT 10;

-- Total number of customer records
SELECT COUNT(*) AS total_customers
FROM e_commerce.customer_details;

-- View table structure
DESCRIBE e_commerce.customer_details;


/* =====================================================
   2. DATA CLEANING
===================================================== */

-- Check null values in important columns
SELECT
COUNT(*) AS total_rows,
SUM(customer_id IS NULL) AS null_customer_id,
SUM(sex IS NULL) AS null_sex,
SUM(customer_age IS NULL) AS null_age,
SUM(tenure IS NULL) AS null_tenure
FROM e_commerce.customer_details;

-- Identify duplicate customer IDs
SELECT customer_id,
COUNT(*) AS duplicate_count
FROM e_commerce.customer_details
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- View duplicate records
SELECT *
FROM e_commerce.customer_details
WHERE customer_id = 10829329;

-- Detect duplicates using ROW_NUMBER()
WITH cte AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY customer_id,
sex,
customer_age,
tenure
) AS rn
FROM e_commerce.customer_details
)

SELECT *
FROM cte
WHERE rn > 1;


/* =====================================================
   3. STANDARDIZE DATA
===================================================== */

-- Check unique gender values
SELECT DISTINCT sex
FROM e_commerce.customer_details;

-- Gender distribution
SELECT sex,
COUNT(*) AS total
FROM e_commerce.customer_details
GROUP BY sex;

-- Replace invalid gender values
UPDATE e_commerce.customer_details
SET sex='Unknown'
WHERE sex='kvkktalepsilindi';

-- Convert values into lowercase and remove spaces
UPDATE e_commerce.customer_details
SET sex = LOWER(TRIM(sex));


/* =====================================================
   4. AGE VALIDATION & DATA CLEANING
===================================================== */

-- Average customer age
SELECT AVG(customer_age)
FROM e_commerce.customer_details;

-- Identify invalid age values
SELECT COUNT(*) AS invalid_age_count
FROM e_commerce.customer_details
WHERE customer_age > 100;

-- View age distribution
SELECT customer_age,
COUNT(*) AS total
FROM e_commerce.customer_details
GROUP BY customer_age
ORDER BY customer_age DESC;

-- Replace invalid age values with NULL
UPDATE e_commerce.customer_details
SET customer_age = NULL
WHERE customer_age < 10
OR customer_age > 100;

-- Fill missing age values using average age
UPDATE e_commerce.customer_details
SET customer_age = (
SELECT avg_customer_age
FROM(
SELECT ROUND(AVG(customer_age))
AS avg_customer_age
FROM e_commerce.customer_details
WHERE customer_age IS NOT NULL
) x
)
WHERE customer_age IS NULL;


/* =====================================================
   5. EXPLORATORY DATA ANALYSIS (EDA)
===================================================== */

-- Total customers
SELECT COUNT(*) AS total_customers
FROM e_commerce.customer_details;

-- Gender distribution
SELECT sex,
COUNT(*) AS total
FROM e_commerce.customer_details
GROUP BY sex;

-- Customer age group analysis
SELECT
CASE
WHEN customer_age < 20 THEN 'Teen'
WHEN customer_age BETWEEN 20 AND 30 THEN '20-30'
WHEN customer_age BETWEEN 31 AND 40 THEN '31-40'
ELSE '40+'
END AS age_group,

COUNT(*) AS total_customers

FROM customer_details

GROUP BY age_group

ORDER BY total_customers DESC;

/* =====================================================
   6. CUSTOMER SEGMENTATION
===================================================== */

-- Customer segmentation based on tenure

SELECT

CASE

WHEN tenure <=12 THEN 'New Customer'

WHEN tenure BETWEEN 13 AND 36
THEN 'Regular Customer'

WHEN tenure BETWEEN 37 AND 72
THEN 'Loyal Customer'

ELSE 'Long-Term Customer'

END AS customer_segment,

COUNT(*) AS total_customers

FROM e_commerce.customer_details

GROUP BY customer_segment

ORDER BY total_customers DESC;


/* =====================================================
   7. TOP CUSTOMERS ANALYSIS
===================================================== */

-- Customers with highest tenure

SELECT customer_id,
customer_age,
tenure

FROM e_commerce.customer_details

ORDER BY tenure DESC

LIMIT 3;


/* =====================================================
   8. CREATE CLEAN DATASET
===================================================== */

-- Create cleaned customer dataset

CREATE TABLE customer_details_clean AS

SELECT DISTINCT *

FROM e_commerce.customer_details;

-- Verify cleaned dataset count
SELECT COUNT(*)
FROM customer_details_clean;












