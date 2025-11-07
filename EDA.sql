-- Exploratory Data Analysis

SELECT *
FROM layoffs_staging2;

-- What is the timeframe for the data?
SELECT
	MIN(`date`),
    MAX(`date`)
FROM layoffs_staging2;

-- Which companies laid off 100% of their employees?

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;



-- Which companies, industries, countries had the most people laid off?

SELECT
	company,
    SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;


SELECT
	industry,
    SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT
	country,
    SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Layoffs by year

SELECT
	YEAR(`date`),
    SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1;


-- Rolling sum of layoffs 

WITH Rolling_Total AS 
(
	SELECT 
		SUBSTRING(`date`,1,7) AS `month`,
        SUM(total_laid_off) AS monthly_layoffs
	FROM layoffs_staging2
    WHERE SUBSTRING(`date`,1,7) IS NOT NULL
    GROUP BY `month`
    ORDER BY 1 ASC
)
SELECT
	`month`,
    monthly_layoffs,
    SUM(monthly_layoffs) OVER(ORDER BY `month`) AS rolling_total
FROM rolling_total;



-- Rank companies based on number of layoffs per year

-- Calculate total layoffs per company per year
WITH total_yearly AS (
	SELECT
		company,
		YEAR(`date`) AS `year`,
		SUM(total_laid_off) AS year_total
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
),
-- Rank companies based on number of layoffs, split up by year
company_rank AS (
	SELECT
		*,
		DENSE_RANK() OVER(PARTITION BY `year` ORDER BY year_total DESC) AS ranking
	FROM total_yearly
	WHERE `year` IS NOT NULL 
)
-- View top 5 companies per year based on total number of layoffs
SELECT *
FROM company_rank
WHERE ranking <= 5
;










