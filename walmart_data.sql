USE walmart_db;

show tables;

drop table walmart;

SELECT * from walmart;

SELECT COUNT(*) FROM walmart;

SELECT 
	payment_method,
    count(*)
FROM walmart
GROUP BY payment_method;

SELECT 
	COUNT(DISTINCT branch)
FROM walmart;

select MAX(quantity) from walmart;

-- Business Problem
-- Q1. Find different payment method and number of transactions, number of qty sold

SELECT 
	payment_method,
    COUNT(*) as no_of_payments,
    sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;
	
-- Q2. Identify the highest-rated category in each branch, displaying the branch, category avg rating

SELECT *
FROM 
(
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking
    FROM walmart
    GROUP BY branch, category
) AS ranked_categories  -- Added alias here
WHERE ranking = 1;


-- Q3. Identify the busiest day for each branch based on the number of transacations


SELECT *
FROM 
(
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_branches
WHERE ranking = 1;

-- Q4. Calculate the totel quantity of items sold per payment method. List payment method and total quantity.

SELECT
	payment_method,
    sum(quantity) as total_quantity
FROM walmart
GROUP BY payment_method;


-- Q5. Determine the average, minimum, and maximum rating of category for each city.
--     List the city, average_rating, min_rating, and max_rating.

SELECT
	city,
	category,
    AVG(rating) AS avg_rating,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category
ORDER BY city, avg_rating DESC;


-- Q6. Calculate the total profit for each category by considering total_profit as
--     (unit_price * quantity* profit_margin).
--     List category and total_profit, ordered from highest to lowest profit.

SELECT
	category,
    SUM(total) as total_revenue,
    SUM(total * profit_margin) as profit
FROM walmart
GROUP BY category;
    

-- Q7. Determine the most common payment method for each Branch.
--     Display Branch and the preferred_payment_method.


WITH CTE
AS
(
	SELECT
		branch,
		payment_method,
		COUNT(*) as total_trans,
		RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
	FROM walmart
	GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE ranking = 1;


-- Q8. Categorize sales into 3 group MORNING, AFTERNOON, EVENING
--     Find out each of the shift and number of invoices

SELECT
	branch,
    CASE 
		WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
	END day_time,
	count(*) as sales
from walmart
GROUP BY branch, day_time
ORDER BY branch, sales DESC;


-- Q9. Identify 5 branch with highest decrese ratio in
--     revenue compare to last year(current year 2023 and last year 2022)


SELECT * FROM walmart;
-- 2022 Sales

WITH revenue_2022
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
	GROUP BY branch
),

revenue_2023
AS
(
	SELECT
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
	GROUP BY branch
)

SELECT 
	ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as current_year_revenue,
    ROUND((CAST(ls.revenue AS DECIMAL(10,2)) - CAST(cs.revenue AS DECIMAL(10,2))) 
    / CAST(ls.revenue AS DECIMAL(10,2)) * 100, 2) AS decs_ratio
FROM revenue_2022 as ls
JOIN 
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY decs_ratio DESC
LIMIT 5;


