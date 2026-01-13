/* Data from an interantional chocolate sales company */


SELECT *
FROM sales
LIMIT 20;

/* First, I notice that the formatting of the column names includes spaces which is likely to cause confusion. 
My solution is to create a staging table to change the names so that the original data is left in its original 
form but I can work on a table that is formatted better for my purposes */

CREATE TABLE `sales_staging` (
  `sales_person` text,
  `country` text,
  `product` text,
  `date` text,
  `amount` bigint DEFAULT NULL,
  `boxes_shipped` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO sales_staging
SELECT *
FROM sales;

SELECT *
FROM sales_staging;

/* While creating the stagin table, I noticed that the date column is a text format.
I want to convert this to a date format */

SELECT 
	`date`,
    str_to_date(`date`, '%d/%m/%Y')
FROM sales_staging;

/* I use a select statement first to make sure that my changes will be correct. Now that I see the results 
of the query, I am comfortable updating the table and making the changes official */

UPDATE sales_staging
SET `date` = str_to_date(`date`, '%d/%m/%Y');

ALTER TABLE sales_staging
MODIFY COLUMN `date` DATE;

SELECT *
FROM sales_staging;


/* Now I can start exploring the data. Firstly, I want to see who the best and worst sales people are
by total amount sold. This will give the company insight into their best and worst performers and can be
used to determine raises, promotions, employees who may need to be reviewed, etc. */

/* Rank each sales person by total amount sold each year */

SELECT
	sales_person,
    YEAR(`date`),
    SUM(amount) AS total_sales,
    RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(amount) DESC) AS ranking
FROM sales_staging
GROUP BY sales_person, YEAR(`date`)
;

/* Turn ranking query into CTE, then find top 3 and bottom 3 performers each year*/

WITH ranking_cte AS (
	SELECT
		sales_person,
		YEAR(`date`) AS `year`,
		SUM(amount) AS total_sales,
		RANK() OVER(PARTITION BY YEAR(`date`) ORDER BY SUM(amount) DESC) AS ranking
	FROM sales_staging
	GROUP BY sales_person, YEAR(`date`)
)

SELECT
	sales_person,
    `year`,
    total_sales,
    ranking
FROM ranking_cte
WHERE ranking <= 3 OR ranking <= 25 AND ranking >= 23;


/* Now I am interested in seeing the top selling products and their total sales. This information can be used
when formulating new products, deciding which products should have special promotions or sales, etc. */

SELECT 
	product,
    SUM(amount) AS total_sales,
    SUM(boxes_shipped) AS total_shipped
FROM sales_staging
GROUP BY product
ORDER BY SUM(amount) DESC;

/* This shows that the #2 best seller is 50% dark bites, with 99% and 85% dark at #6 and #7, 
whereas 70% dark is the worst seller. This suggests that perhaps having too many % dark options hinders sales of the other options */


/* Finally I am interested in looking at a rolling total of overall sales by month. Large jumps will show times when sales were
particularly high, whereas small increases will show when sales have been low. This information can be combined with other information
from the company (advertising and/or marketing of a given time) to attempt to answer the question of why sales are high/low at a given time */

WITH rt AS 
(
	SELECT 
		SUBSTRING(`date`,1,7) AS `month`,
        SUM(amount) AS monthly_sales
	FROM sales_staging
    GROUP BY `month`
    ORDER BY 1 ASC
)

SELECT
	`month`,
    monthly_sales,
    SUM(monthly_sales) OVER(ORDER BY `month`) AS rolling_total
FROM rt;































