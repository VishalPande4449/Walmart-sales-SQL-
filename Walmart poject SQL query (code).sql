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


UPDATE sales            
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END
);


-- Day_name
SELECT date,        
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);    
UPDATE sales
SET day_name = DAYNAME(date);    



-- month_name


SELECT date,        
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);   

UPDATE sales
SET month_name = MONTHNAME(date);         




---------------------------------------------------------------------------------------------------
-- Generic questions --

-- How many unique cities does the data have?

SELECT DISTINCT city    
FROM sales;


-- How many branches each city has?
SELECT DISTINCT city,    
        branch    
FROM sales;

-----------------------------------------------------------------------------------------------------------------
-- PRODUCT questions ------------------------

-- how many unique product lines does the data have?
SELECT 
   COUNT(DISTINCT product_line)      
FROM sales;

-- what is the most common payment method?
SELECT payment,
      COUNT(payment) AS count   
FROM sales 
GROUP BY payment;   

-- What is the most selling product line?
SELECT product_line,
       COUNT(product_line) AS count 
FROM sales
GROUP BY product_line
ORDER BY count DESC;     


-- What is the total revenue by month?(revenue in Jan, FEB, march)
SELECT month_name AS month,       
      SUM(total) AS total_revenue     
FROM sales 
GROUP BY month_name                  
ORDER BY total_revenue DESC;          

-- Which month has the largest cogs(cost of goods sold)
SELECT month_name,                      
      SUM(cogs) AS total_cogs   
FROM sales 
GROUP BY month_name                 
ORDER BY total_cogs DESC;  

-- Which product line has the largest revenue?
SELECT product_line AS product,       
      SUM(total) AS total_revenue    
FROM sales 
GROUP BY product_line                  
ORDER BY total_revenue DESC;  


-- What is the city with the largest revenue?
SELECT city,      
      SUM(total) AS total_revenue    
FROM sales 
GROUP BY city                 
ORDER BY total_revenue DESC;  

-- What product line has the largest VAT?
SELECT product_line AS product,       
      SUM(tax_pct) AS VAT  
FROM sales 
GROUP BY product_line                  
ORDER BY VAT DESC;  

-- Fetch each product line and add a column of rating ie Good, Bad (Combo of product line and cogs but with a condition). Good if its gretaer than average sales, bad if it less than average sales.
SELECT product_line,
  CASE                                 
	  WHEN cogs > (SELECT AVG(cogs)   
	FROM sales) 
      THEN 'Good'                     
	  ELSE 'Bad'                       
  END AS rating                      
FROM sales;

-- Which branch sold more products than average products sold?
SELECT branch,
     SUM(quantity)  
FROM sales 
GROUP BY branch  
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);     

-- What is the most common product line by gender
SELECT
	gender,                                    
    product_line,
    COUNT(gender) AS total_count               
FROM sales 
GROUP BY gender,product_line                   
ORDER BY total_count DESC;

-- What is the average rating of each product line?

SELECT 
     AVG(rating) AS avg_rating,      
     product_line
FROM sales
GROUP BY product_line                
ORDER BY avg_rating DESC;


------------------------------------------------------------------------------------------------------------------
-- Sales questions -----------------------------------------------------------------------------------------------

-- Number of sales each time of the day every weekend
SELECT 
     time_of_day,                                      
     COUNT(quantity) AS total_sales                    
FROM sales
WHERE day_name = "SUNDAY"                               
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
    COUNT(customer_type) AS customer              
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
WHERE branch = "C"                              
GROUP BY gender                               
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
     AVG(rating) AS ratings       
FROM sales
GROUP BY time_of_day               
ORDER BY ratings DESC;             

-- Which time of the day do customerrs give more rating( number of rating) acc to branches

SELECT 
     time_of_day,
     COUNT(rating) AS ratings
FROM sales 
WHERE branch = "A"                           
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
