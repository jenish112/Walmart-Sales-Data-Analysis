-- Create Database
CREATE DATABASE Walmart;

-- Create Table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL, -- (COST OF GOODS)  
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- -------------------------------------- Feature Engineering -------------------------------------------------
-- i) Add the time_of_day
Select
	time,
    (CASE 
		When `time` Between "00:00:00" AND "12:00:00" Then "Morning"
		When `time` Between "12:00:01" AND "16:00:00" Then "Afternoon"
        else "Evening"
        End) AS time_of_day
from sales;

Alter table sales Add column time_of_day varchar(20);

UPDATE sales 
SET time_of_day = (
	CASE 
		When `time` Between "00:00:00" AND "12:00:00" Then "Morning"
		When `time` Between "12:00:01" AND "16:00:00" Then "Afternoon"
        else "Evening"
	End
);

-- ii) Add day_name
SELECT 
	date,
    DAYNAME(date) AS day_name
FROM 
	sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = (
DAYNAME(date)
);

-- iii) add month_name
SELECT 
	date,
    MONTHNAME(date)
FROM
	sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);
-- --------------------------------------------------------------------------------------------------------

-- ---------------------------------------- EDA -----------------------------------------------------------
-- ----------------------------------- Generic Questions --------------------------------------------------

-- 1) How many unique cities does the data have?

SELECT 
	DISTINCT city  
FROM 
	sales;

-- 2) In which city is each branch?

SELECT 
	DISTINCT city, branch
FROM 
	sales;

-- -------------------------------------------------------------------------------------------------------

-- -------------------------------- Product Question -----------------------------------------------------

-- How many unique product lines does the data have?

SELECT 
	COUNT(DISTINCT product_line)
FROM
	sales;

-- What is the most common payment method?

SELECT
	payment,
	COUNT(payment) AS cnt_payment
FROM
	sales
GROUP BY payment
ORDER BY cnt_payment DESC;

-- What is the most selling product line?

SELECT 
	product_line,
	COUNT(product_line) AS cnt_product_line
FROM 
	sales
GROUP BY product_line
ORDER BY cnt_product_line DESC;

-- What is the total revenue by month?

SELECT 
	month_name AS month,
	SUM(total) AS total_revenue
FROM 
	sales
GROUP BY month_name
ORDER BY total_revenue DESC;


-- What month had the largest COGS?

SELECT 
	month_name AS month,
	SUM(cogs) AS cogs
FROM
	sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?

SELECT 	
	product_line,
	SUM(total) AS total_revenue
FROM	
	sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?

SELECT 
	city,
    SUM(total) AS total_revenue
FROM 
	sales
GROUP BY city
ORDER BY total_revenue DESC;

-- What product line had the largest VAT? (VALUE ADD TAX)

SELECT 
	product_line,
    AVG(tax_pct) AS tax_pct
FROM 
	sales
GROUP BY product_line
ORDER BY tax_pct DESC;

-- Fetch each product line and add a column to those lines showing "Good", and "Bad". Good if it's greater than average sales

SELECT 
	product_line,
    ROUND(SUM(total), 2) AS total_revenue,
    CASE WHEN 
		AVG(total) > (SELECT AVG(total) FROM sales) THEN "Good"
		ELSE "BAD"
	END AS sales_status
FROM 	
	sales
GROUP BY product_line;

-- Which branch sold more products than the average product sold?

SELECT 
	branch,
    SUM(quantity) AS total_quantity
FROM 
	sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales)
ORDER BY total_quantity DESC;

-- What is the most common product line by gender?

SELECT
	gender,
	product_line,
	COUNT(gender) AS cnt_gender
FROM 
	sales
GROUP BY gender, product_line
ORDER BY cnt_gender;

-- What is the average rating of each product line?

SELECT 
	product_line,
	ROUND(AVG(rating), 2) AS avg_rating
FROM 	
	sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- -----------------------------------------------------------------------------------------------------------

-- ------------------------------------ Customer Question ----------------------------------------------------

-- How many unique customer types does the data have?

SELECT 
	DISTINCT customer_type
FROM
	sales;

-- How many unique payment methods does the data have?

SELECT 
	DISTINCT payment,
    COUNT(payment) AS cnt
FROM
	sales
GROUP BY payment
ORDER BY cnt DESC;
    
-- Which customer type buys the most?

SELECT
	customer_type,
    COUNT(*) AS cnt
FROM 
	sales
GROUP BY customer_type
ORDER BY cnt;

-- What is the gender of most of the customers?

SELECT 
	gender,
	COUNT(*) as cnt
FROM 
	sales
GROUP BY gender
ORDER BY cnt DESC;

-- What is the gender distribution per branch?

SELECT
	gender,
	COUNT(*) as cnt_gender
FROM
	sales
WHERE branch = "C"
GROUP BY gender
ORDER BY cnt_gender DESC;

-- Which time of the day do customers give the most ratings?

SELECT 
	time_of_day,
	AVG(rating) AS cnt_rating
FROM 
	sales
GROUP BY time_of_day
ORDER BY cnt_rating DESC;

-- Which time of the day do customers give the most ratings per branch?

SELECT
	time_of_day,
    AVG(rating) avg_rating
FROM 
	sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?

SELECT
	day_name,
    AVG(rating) AS avg_rating
FROM
	sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- ---------------------------------------------------------------------------------------------------------

-- ---------------------------------------- Sales Question -------------------------------------------------

-- Number of sales made at each time of the day per weekday?

SELECT 
	time_of_day,
	COUNT(*) AS num_sales
FROM
	sales
WHERE day_name="SUNDAY"
GROUP BY time_of_day
ORDER BY num_sales DESC;

-- Which of the customer types brings the most revenue?

SELECT 
	customer_type,
    SUM(TOTAL) AS sum_total
FROM 
	sales
GROUP BY customer_type
ORDER BY sum_total DESC;

-- Which city has the largest tax/VAT percent?

SELECT
	city,
    AVG(tax_pct) AS sum_tax_pct
FROM 
	sales
GROUP BY city
ORDER BY sum_tax_pct DESC;

-- Which customer type pays the most in VAT?

SELECT
	customer_type,
    AVG(tax_pct) AS tax_pct
FROM
	sales
GROUP BY customer_type
ORDER BY tax_pct DESC;

-- Which product line had the most average cogs (Cost Of Goods) and gross income?

SELECT
	product_line,
	AVG(cogs) AS avg_cogs,
    AVG(gross_income) AS avg_income
FROM 
	sales
GROUP BY product_line
ORDER BY avg_income DESC;

-- In which month had the highest average rating?

SELECT 
	month_name,
    AVG(rating) AS avg_rating
FROM	
	sales
GROUP BY month_name
ORDER BY avg_rating DESC;

-- Which of the genders brings the most gross income?

SELECT
	gender,
    AVG(gross_income) AS avg_income
FROM
	sales
GROUP BY gender
ORDER BY avg_income DESC;

-- ----------------------------------------------------------------------------------------------------------
-- --------------------------------------------- The End ----------------------------------------------------
