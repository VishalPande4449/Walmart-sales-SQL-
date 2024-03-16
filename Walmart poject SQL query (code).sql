-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;


-- Create table
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
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);



-- Feature engineering 

-- time_of_day - Sorting acc to morning, afternoon, evening to understand what timimg a store is maximum selling.
SELECT
	time,
	(CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);     -- create a new table

-- For this to work turn off safe mode for update
-- Edit > Preferences > SQL Edito > scroll down and toggle safe mode
-- Reconnect to MySQL: Query > Reconnect to server
UPDATE sales              -- data will be filtered and put into newly made column
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Day_name
-- Adding column name day_name for transactions happenend on a specific day (monday,tuesday etc) to understand which day a store performs best.
SELECT date,        -- query to sort date data acc to day names
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);    -- creating a null table 
UPDATE sales
SET day_name = DAYNAME(date);    -- updating data in day_name columns



-- month_name
-- The exact month in which the sale has happened, to determine which months have the most profit.

SELECT date,        -- query to sort date data acc to month names
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);   -- creates new table

UPDATE sales
SET month_name = MONTHNAME(date);         -- updating data in month_name columns




---------------------------------------------------------------------------------------------------
-- Generic questions --

-- How many unique cities does the data have?

SELECT DISTINCT city     -- DISTINCT function sorts unique values
FROM sales;


-- How many branches each city has?
SELECT DISTINCT city,    -- putting city, branch gives branch names according to cities 
        branch    
FROM sales;

-----------------------------------------------------------------------------------------------------------------
-- PRODUCT questions ------------------------

-- how many unique product lines does the data have?
SELECT 
   COUNT(DISTINCT product_line)      -- count will actually count the values that are asked 
FROM sales;

-- what is the most common payment method?
SELECT payment,
      COUNT(payment) AS count    -- counting payment values i.e. count of cash - 344, credit - 309 etc
FROM sales 
GROUP BY payment;   -- this GROUP BY payment will give out the numbers accordingly with payment method cash, credit etc

-- What is the most selling product line?
SELECT product_line,
       COUNT(product_line) AS count 
FROM sales
GROUP BY product_line
ORDER BY count DESC;     --  this will give highest number of counts in product line on top.


-- What is the total revenue by month?(revenue in Jan, FEB, march)
SELECT month_name AS month,       
      SUM(total) AS total_revenue     -- Here SUM function is used to total all the revenue for 1 month, then next month.
FROM sales 
GROUP BY month_name                   -- grouping is done by name of months ie Jan, Feb, March.
ORDER BY total_revenue DESC;          -- the table is ordered according to total revenue in descending order

-- Which month has the largest cogs(cost of goods sold)
SELECT month_name,                      -- Same as above, combo of cogs and month
      SUM(cogs) AS total_cogs   
FROM sales 
GROUP BY month_name                 
ORDER BY total_cogs DESC;  

-- Which product line has the largest revenue?
SELECT product_line AS product,       
      SUM(total) AS total_revenue     -- Same as above, just a combo of product line and total 
FROM sales 
GROUP BY product_line                  
ORDER BY total_revenue DESC;  


-- What is the city with the largest revenue?
SELECT city,      
      SUM(total) AS total_revenue     -- Same as above, just a combo of city and total 
FROM sales 
GROUP BY city                 
ORDER BY total_revenue DESC;  

-- What product line has the largest VAT?
SELECT product_line AS product,       
      SUM(tax_pct) AS VAT  -- Same as above, just a combo of product line and VAT(tax_pct)
FROM sales 
GROUP BY product_line                  
ORDER BY VAT DESC;  

-- Fetch each product line and add a column of rating ie Good, Bad (Combo of product line and cogs but with a condition). Good if its gretaer than average sales, bad if it less than average sales.
SELECT product_line,
  CASE                                -- CASE WHEN ELSE just like if else 
	  WHEN cogs > (SELECT AVG(cogs)   -- first condition 
	FROM sales) 
      THEN 'Good'                     
	  ELSE 'Bad'                        -- 2nd condition ie cogs < average cogs 
  END AS rating                       -- New column which will constitute good or bad rating
FROM sales;

-- Which branch sold more products than average products sold?
SELECT branch,
     SUM(quantity)  -- SUM of products sold(quantity)
FROM sales 
GROUP BY branch  
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);      -- HAVING is used to sort as this condition contains SUM and algorithm, after GROUP BYwe have to use 


-- What is the most common product line by gender
SELECT
	gender,                                    -- 2 columns aree related in a table ie Maximum buying gender, product_line, total count(no. of male/female buyers of a product line)
    product_line,
    COUNT(gender) AS total_count               -- counting maximum buying gender for a product line
FROM sales 
GROUP BY gender,product_line                   -- as both columns need to be showed and data is sported acc to both, we use both in here 
ORDER BY total_count DESC;

-- What is the average rating of each product line?

SELECT 
     AVG(rating) AS avg_rating,      -- AVG function is used to calculate average of ratings
     product_line
FROM sales
GROUP BY product_line                
ORDER BY avg_rating DESC;


------------------------------------------------------------------------------------------------------------------
-- Sales questions -----------------------------------------------------------------------------------------------

-- Number of sales each time of the day every weekend
SELECT 
     time_of_day,                                      -- Each time of day = morning, afternoon, evening
     COUNT(quantity) AS total_sales                    -- quanity = units sold in a transaction. and sorting it acc to units sold in a time of day
FROM sales
WHERE day_name = "SUNDAY"                               -- We have to sort acc to every day of the week, hence usinhg WHERE condition one by one for each day
GROUP BY time_of_day
ORDER BY total_sales DESC;


-- Which of the customer type brings the most revenue?

SELECT 
     customer_type,
     SUM(total) AS revenue
FROM sales
GROUP BY customer_type
ORDER BY revenue DESC;

-- Which city has the largest tax percent/VAT?

SELECT 
	city,
    SUM(tax_pct) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most tax?

SELECT 
	customer_type,
    SUM(tax_pct) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

------------------------------------------------------------------------------------------------------------
-- Customer questions---------------------------------------------------------------------------------------


-- How many unique customer types does the data have?

SELECT DISTINCT customer_type
FROM sales;

-- How mahy unique payment methods does the data have?

SELECT DISTINCT payment AS payment_methods
FROM sales;

-- Which is the most common customer_type?

SELECT customer_type,
    COUNT(customer_type) AS customer               -- Here customer_type is Normal or member, But customer is total count of each one of these 2 entities.
FROM sales
GROUP BY customer_type
ORDER BY customer DESC;

-- Which customer type buys the most?
SELECT 
     customer_type,
     SUM(total) AS items_bought_worth
FROM sales
GROUP BY customer_type
ORDER BY items_bought_worth DESC;

-- What is the gender of most of the customers?

SELECT 
     gender,
     COUNT(gender) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch?

SELECT 
     gender,                                    
     COUNT(gender) AS gender_cnt          
FROM sales
WHERE branch = "C"                               -- This C will change to A and B manually and we will get data accordingly
GROUP BY gender                                -- NOTE - Here we can only mention the column acc to which we have to sort data, We nhave sort acc to gender here
ORDER BY gender_cnt DESC;

-- What time of day customers gives more ratings (number of rating)?

SELECT 
     time_of_day,
     COUNT(rating) AS ratings
FROM sales
GROUP BY time_of_day
ORDER BY ratings DESC;
	
-- What time of day customers gives more ratings (top ratings-5star,6star,7star)?
SELECT 
     time_of_day,
     AVG(rating) AS ratings        -- AVG will give out avg rating given by customer in a time of day
FROM sales
GROUP BY time_of_day               
ORDER BY ratings DESC;             -- This AVG will be compared and maximum ratings(acc. to rating) in a specific time will be on top

-- Which time of the day do customerrs give more rating( number of rating) acc to branches

SELECT 
     time_of_day,
     COUNT(rating) AS ratings
FROM sales 
WHERE branch = "A"                           -- Here we have just added the condition which is branch and this is done by WHERE clause
GROUP BY time_of_day
ORDER BY ratings DESC;


-- Which day of the week has best avg ratings?

SELECT 
     day_name,
     AVG(rating) AS avg_ratings
FROM sales
GROUP BY day_name
ORDER BY avg_ratings DESC;


-- Which day of the week has best avg ratings acc to branch?
SELECT 
     day_name,
     AVG(rating) AS avg_ratings
FROM sales
WHERE branch = "A"
GROUP BY day_name
ORDER BY avg_ratings DESC;
