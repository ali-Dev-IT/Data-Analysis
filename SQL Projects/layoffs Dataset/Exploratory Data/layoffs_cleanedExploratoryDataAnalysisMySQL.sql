-- < EDA > < LAYOFFS_CLEANED > < MySQL > < ALI SHAHHOUD THE ANALYST >

-- Here we are just going to explore the data and find trends or patterns or anything interesting like outliers

-- normally when you start the EDA process you have some idea of what you're looking for

-- with this info we are just going to look around and see what we find!

-- EASIER QUERIES

SELECT *
FROM layoffs_cleaned;

SELECT MAX(total_laid_off)
FROM layoffs_cleaned;

-- Looking at Percentage to see how big these layoffs were
SELECT MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM layoffs_cleaned
WHERE percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1;
-- these are mostly startups it looks like who all went out of business during this time

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT *
FROM layoffs_cleaned
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- BritishVolt looks like an EV company, Quibi! I recognize that company - wow raised like 2 billion dollars and went under - ouch

-- SOMEWHAT TOUGHER AND MOSTLY USING GROUP BY--------------------------------------------------------------------------------------------------

-- Companies with the biggest single Layoff
SELECT company, total_laid_off
FROM layoffs_cleaned
ORDER BY 2 DESC
LIMIT 5;

-- Companies with the most Total Layoffs
SELECT company, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

-- by location
SELECT location, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- by country
SELECT country, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY country
ORDER BY 2 DESC;

-- by year
SELECT YEAR(date), SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY YEAR(date);

-- by industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY industry
ORDER BY 2 DESC;

-- by stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_cleaned
GROUP BY stage
ORDER BY 2 DESC;

-- TOUGHER QUERIES------------------------------------------------------------------------------------------------------------------------------------

-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
-- I want to look at
WITH Company_Year AS (SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_laid_offs
                      FROM layoffs_cleaned
                      GROUP BY company, YEAR(date)),
     Company_Year_Rank AS (SELECT *, DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_offs DESC) AS ranking
                           FROM Company_Year)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5
  AND year IS NOT NULL;

-- Rolling Total of Layoffs Per Month
SELECT SUBSTRING(date, 1, 7) as `month`, SUM(total_laid_off) AS total_laid_off
FROM layoffs_cleaned
WHERE SUBSTRING(date, 1, 7) IS NOT NULL
GROUP BY `month`;

-- now use it in a CTE so we can query off of it
WITH Month_CTE AS (SELECT SUBSTRING(date, 1, 7) as `month`, SUM(total_laid_off) AS total_laid_offs
                   FROM layoffs_cleaned
                   WHERE SUBSTRING(date, 1, 7) IS NOT NULL
                   GROUP BY `month`)
SELECT *,
       SUM(total_laid_offs) OVER (PARTITION BY SUBSTRING(`month`, 1, 4) ORDER BY `month` ASC) as rolling_total_layoffs
FROM Month_CTE;