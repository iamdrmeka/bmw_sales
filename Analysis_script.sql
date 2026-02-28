USE bmw_sales;
-
-- --Now the data is Clean, Let's dive in.
-- Evaluate all data
SELECT *
FROM bmw;
-- count the number of records
SELECT count(*)
from bmw;
-- CHECK FOR NULL VALUES

-- Total revenue for the period under review
SELECT FORMAT(SUM(revenue), 0) AS TOTAL_REVENUE
FROM bmw;
-- Period Under Review --
select DISTINCT(Year),
    (
        select COUNT(DISTINCT(Year))
        from bmw
    ) Num_of_years
from bmw
order by year ASC;
-- Models and count
select COUNT(DISTINCT(Year))
from bmw;
SELECT DISTINCT(Model) Models,
    (
        select COUNT(DISTINCT(model)) model_count
        from bmw
    ) Total_model_count
from bmw;
-- Regions
SELECT DISTINCT(region) AS REGIONS
from bmw;
-- Total Units Sold
SELECT year,
    FORMAT(sum(sales_volume), 2) as Total_sales
from bmw
group by year
order by sum(sales_volume) DESC;
--  tOTAL REVENUE
SELECT year,
    FORMAT(sum(REVENUE), 2) AS Total_revenue
from bmw
group by year
order by sum(sales_volume) DESC;
-- Total sales
SELECT year,
    FORMAT(sum(sales_volume), 2)
from bmw
group by year
order by sum(sales_volume) DESC;
-- Total Units Sold year by Year plus revenue
SELECT Year,
    FORMAT(sum(sales_volume), 2) as Total_sales,
    FORMAT(sum(revenue), 2) as REVENUE
from bmw
group by year
order by year ASC;

-- YoY Growth on revenue
WITH yearly_revenue AS (
    SELECT year,
        sum(revenue) as TOTAL_REVENUE,
        IFNULL(
            lag(sum(revenue)) over(
                order by year
            ),
            0
        ) previous_year,
        IFNULL(
            sum(revenue) - lag(sum(revenue)) over(
                order by year
            ),
            0
        ) AS DIFF
    FROM BMW
    GROUP BY YEAR
    ORDER BY YEAR
)
SELECT Year,
    TOTAL_REVENUE,
    Previous_year,
    ROUND((100 * DIFF) / Total_Revenue, 2) as YOY_growth
from yearly_revenue;
-- YoY growth on sales_volume
-- YoY Growth on sales_volume
WITH yearly_sales AS (
    SELECT year,
        sum(Sales_Volume) as TOTAL_sales,
        IFNULL(
            lag(sum(Sales_Volume)) over(
                order by year
            ),
            0
        ) previous_year,
        IFNULL(
            sum(Sales_Volume) - lag(sum(Sales_Volume)) over(
                order by year
            ),
            0
        ) AS DIFF
    FROM BMW
    GROUP BY YEAR
    ORDER BY YEAR
)
SELECT Year,
    Total_sales,
    Previous_year,
    ROUND((100 * DIFF) / Total_sales, 2) as YOY_growth
from yearly_sales;
--
--
--
--
-- Regional analysis
Select REGION,
    FORMAT(SUM(revenue), 2) REVENUE
FROM BMW
GROUP BY region
ORDER BY SUM(revenue) DESC;
-- top region -sales
Select region,
    FORMAT(SUM(sales_volume), 2) SALES
FROM BMW
GROUP BY region
ORDER BY SUM(sales_volume) DESC;
-- OVERVIEW 
-- OF
-- GROWTH TRENDS
-- 
--
---
-- bEST PERFORMING AND WORST PERFOMING YEARS
WITH low_years AS 
(select 
`year`,
sum(revenue) as Total_revenue,
rank() over(order by sum(revenue) ASC) as RN
from bmw
GROUP BY `year`),
high_years AS
 (SELECT 
 `year`,
 sum(revenue) AS Total_revenue,
RANK() OVER(order by sum(revenue) DESC) AS RN
from bmw
GROUP BY `year`)
select
lY.RN 'S/N',
LY.`year` AS LOW_YEARS,
FORMAT(LY.total_revenue, 2) AS total_revenue,
HY.`YEAR` AS HIGH_YEARS,
FORMAT(HY.total_revenue, 2) AS total_revenue
FROM low_years LY
inner join high_years HY ON LY.RN = HY.RN
WHERE lY.RN <= 5;
--
--
-- Growth trend from 2010 to 2014
select
year,
 region,
total_revenue,
previous_year_revenue,
growth
from (
Select
region,
year,
sum(revenue) as Total_revenue,
lag(sum(revenue)) over(partition by region order by year) as previous_year_revenue,
sum(revenue) - lag(sum(revenue)) over(partition by region order by year) as Profit,
(100 * (sum(revenue) - lag(sum(revenue)) over(partition by region order by year))) / sum(revenue) AS Growth
from bmw
GROUP BY year, region
order by region, year ASC)t;
--

--
-- Average Growth of Revenue for all region accross the 15 years
select region,
    ROUND(AVG(GROWTH), 2) AS avg_growth -- lag(total_revenue) over(partition by region order by year) as previous_year_growth
from (
        Select region,
            year,
            sum(revenue) as Total_revenue,
            lag(sum(revenue)) over(
                partition by region
                order by year
            ) as previous_year_revenue,
            sum(revenue) - lag(sum(revenue)) over(
                partition by region
                order by year
            ) as Profit,
            (
                100 * (
                    sum(revenue) - lag(sum(revenue)) over(
                        partition by region
                        order by year
                    )
                )
            ) / sum(revenue) AS Growth
        from bmw
        GROUP BY year,
            region
        order by region,
            year ASC
    ) t
GROUP BY REGION;
--
--
--
-- dIFFERENCE BETWEEN 2010 REVENUE AND 2014 REVENUE AND % GROWTH REGIONAL
WITH revenue_stat AS (
    SELECT region,
        SUM(
            CASE
                WHEN YEAR = 2010 THEN revenue
                ELSE 0
            END
        ) AS REVENUE_2010,
        SUM(
            CASE
                WHEN YEAR = 2014 THEN revenue
                ELSE 0
            END
        ) AS REVENUE_2014,
        (
            SUM(
                CASE
                    WHEN YEAR = 2014 THEN revenue
                    ELSE 0
                END
            ) - SUM(
                CASE
                    WHEN YEAR = 2010 THEN revenue
                    ELSE 0
                END
            )
        ) as revenue_change
    FROM bmw
    group by Region
)
select Region,
    Revenue_2010,
    Revenue_2014,
    revenue_change,
    round((100 * revenue_change) / revenue_2010, 2) as percent_growth
from revenue_stat
order by percent_growth DESC;
--
--

--
--
-- Percentage growth of sales between 2010 and 2014
WITH Sales_Volume_stat AS (SELECT 

region,
SUM(CASE WHEN YEAR = 2010 THEN Sales_Volume ELSE 0 END) AS Sales_Volume_2010,
SUM(CASE WHEN YEAR = 2014 THEN Sales_Volume ELSE 0 END) AS Sales_Volume_2014,
(SUM(CASE WHEN YEAR = 2014 THEN Sales_Volume ELSE 0 END) - SUM(CASE WHEN YEAR = 2010 THEN Sales_Volume ELSE 0 END)) as Sales_Volume_change
FROM bmw
group by Region)

select 
Region,
Sales_Volume_2010,
Sales_Volume_2014,
Sales_Volume_change,
round((100 * Sales_Volume_change) / Sales_Volume_2010, 2) as percent_growth
from
Sales_Volume_stat
order by percent_growth DESC;

--
--
-- COUNT OF LOW AND HIGH SALES ACCROSS REGIONS
SELECT 
region,
FORMAT(sum(case when Sales_Classification = 'high' then 1 else 0 end), 0) high_sales_count,
FORMAT(sum(case when Sales_Classification = 'low' then 1 else 0 end), 0)  low_sales_count
from bmw
group by region;

--
--

-- REVENUE PER MODEL FOR THE PERIOD UNDER REVIEW
SELECT model,
    FORMAT(sum(Revenue), 2) as REVENUE
from bmw
GROUP BY MODEL
ORDER BY REVENUE DESC;
-- SALES PER MODEL FOR THE PERIOD UNDER REVIEW
SELECT model,
    FORMAT(sum(Sales_Volume), 2) as TOTAL_SALES
from bmw
GROUP BY MODEL
ORDER BY SUM(Sales_Volume) DESC;
-- AVERAGE PRICE of the MODELS
SELECT model as MODEL,
    FORMAT(ROUND(AVG(Price_USD), 2), 2) as Avg_price
FROM bmw
GROUP BY model
order BY Avg_price DESC;

-- Model perfomance accross the regions
SELECT
region,
model,
FORMAT(sum(sales_volume), 2) AS SALES,
FORMAT(ROUND(avg(Price_USD), 2), 2) AVG_PRICE
from bmw
 group by region, model
 order by region, sales DESC;

 --
 --
 -- Fuel type analysis

-- sales
select 
fuel_type,
FORMAT(sum(Sales_Volume), 2) sales
from bmw
GROUP BY Fuel_Type
order by sales DESC;

-- REVENUE
SELECT 
fuel_type,
FORMAT(SUM(revenue), 2) as Revenue
from bmw
GROUP BY Fuel_Type
ORDER BY revenue DESC;

-- FUEL TYPE PREFERENCE BY REGIONS
-- SALES

WITH fuel_calc AS (SELECT
region,
fuel_type,
FORMAT(sum(sales_volume), 2) as sales
from bmw
GROUP BY region, Fuel_Type
order by region ASC, sales DESC)

Select 
region,
fuel_type,
sales,
rank() over(partition by region order by sales DESC) as Position_in_region
from fuel_calc;
--
-- FUEL TYPE REVENUE BY REGIONS
--
WITH fuel_calc AS (SELECT
region,
fuel_type,
FORMAT(sum(revenue), 2) as sales
from bmw
GROUP BY region, Fuel_Type
order by region ASC, sales DESC)

Select 
region,
fuel_type,
sales,
rank() over(partition by region order by sales DESC) as Position_in_region
from fuel_calc;
--
-- FAVOURITE TRANSMISION TYPE
SELECT 
region,
Transmission,
format(SUM(SALES_VOLUME), 2) AS sales
FROM BMW
group by transmission, region
order by region, sum(sales_volume);

-- 
--
-- Engine Size
SELECT 
CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END as Engine_size,
FORMAT(SUM(sales_volume), 2) as SALES_VOLUME
FROM BMW
group by CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END
ORDER BY sum(sales_volume) desc;
---
--
-- Engine size preference by regions
SELECT 
region,
CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END as Engine_size,
FORMAT(SUM(sales_volume), 2) as SALES_VOLUME
FROM BMW
group by 
CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END, region
ORDER BY region, sum(sales_volume) desc;
--
--
--Engine size : sales and revenue
SELECT 
CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END as Engine_size,
FORMAT(AVG(PRICE_USD), 2)  Avg_Price,
 FORMAT(SUM(SALES_VOLUME), 2) TOTAL_SALES,
 FORMAT(SUM(REVENUE), 2) AS REVENUE
FROM BMW
group by CASE
	WHEN engine_size_L < 2 THEN '1.0 - 1.9L'
	WHEN engine_size_L < 3 THEN '2.0 - 2.9L'
	WHEN engine_size_L < 4 THEN '3.0 - 3.9L'
	WHEN engine_size_L < 5 THEN '4.0 - 4.9L'
    ELSE '5L'
END
ORDER BY AVG(PRICE_USD) desc;


--
-- mILEAGE AND PRICE
select 
CASE
	WHEN mileage_kms <= 50000 THEN 'Low Mileage(≤ 50,000km)'
    WHEN mileage_kms <= 100000 THEN 'medium Mileage(50,001 - 100,000 km)'
    ELSE 'High Mileage(100,000 km +)'
END as mileagge,
FORMAT(avg(price_usd), 2) AS  AVG_PRICE,
FORMAT(SUM(Sales_Volume), 2) AS TOTAL_SALES
from bmw
group by 
CASE
WHEN mileage_kms <= 50000 THEN 'Low Mileage(≤ 50,000km)'
    WHEN mileage_kms <= 100000 THEN 'medium Mileage(50,001 - 100,000 km)'
    ELSE 'High Mileage(100,000 km +)'
END
ORDER BY avg(price_usd) DESC;
--









