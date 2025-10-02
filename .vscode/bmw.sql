select count(*) /*count the number of data we're working on*/
from nimrodnewdb.bmw;

SELECT * /*RETRIEVE ALL THE DATA*/
FROM Nimrodnewdb.bmw;

SELECT /*count the number of models we're working*/
COUNT(DISTINCT model) `NUMBER OF MODELS`
FROM nimrodnewdb.bmw;

/*Adding a revenue column to the table and setting new values for it*/
--revenue = price_usd * Sales_volume

ALTER table nimrodnewdb.bmw
ADD COLUMN Revenue DECIMAL(17,2);

UPDATE nimrodnewdb.bmw
SET Revenue = price_USD * Sales_volume;


SELECT model, YEAR,
FORMAT(SUM(sales_Volume), 2) sales_Volume,
FORMAT(AVG(price_USD), 2) AVERAGE_PRICE,
FORMAT(COUNT(MODEL), 2) MODELS_SOLD,
sum(count(model)) over () sum_of_sales
FROM nimrodnewdb.bmw
GROUP BY Model, YEAR
order by Model, YEAR;

/*Most Succesful model -  first we check sales by models and then we check the model with the highest sale acrros al regions*/

SELECT 
model,
FORMAT(sum(sales_volume), 2) AS Volume_Sold
FROM nimrodnewdb.bmw
GROUP BY Model
ORDER BY sum(sales_volume) DESC; 

/*ALL TIME MOST succesful Model*/
SELECT 
model AS `BEST MODEL`,
FORMAT(sum(sales_volume), 2) AS Volume_Sold
FROM nimrodnewdb.bmw
GROUP BY Model
ORDER BY sum(sales_volume) DESC
LIMIT 1; 

/*CHECKING MODELS BY REVUNE GENERATED*/
SELECT 
model,
FORMAT(SUM(REVENUE), 2) AS TOTAL_REVENUE
FROM nimrodnewdb.bmw
GROUP BY model
ORDER BY sum(revenue) DESC;

/*--Most Gross renenue Generated*/
SELECT 
model,
FORMAT(SUM(REVENUE), 2) AS TOTAL_REVENUE
FROM nimrodnewdb.bmw
GROUP BY model
ORDER BY sum(revenue) DESC
LIMIT 1;

/*Revenue by Year */
SELECT year, FORMAT(sum(sales_volume), 2) SALES,
FORMAT(sum(revenue), 2) REVENUE,
(SELECT FORMAT(sum(revenue), 2) FROM nimrodnewdb.bmw) AS ALL_TIME_REVENUE
FROM nimrodnewdb.bmw
GROUP BY Year
ORDER BY sum(Revenue) DESC;

SELECT count(DISTINCT year)
FROM nimrodnewdb.bmw;/*WE'RE WORKING WITH 15 YEARS*/

/*Year by Year Growth/SALES*/
select 
year,
TOTAL_SALES,
TOTAL_SALES - LAG(TOTAL_SALES) OVER(ORDER BY year) AS YEAR_ON_YEAR_DIFF
FROM
(
SELECT
year, 
sum(sales_volume) AS TOTAL_SALES
from nimrodnewdb.bmw
GROUP BY YEAR
)Yearly_sales
ORDER BY YEAR;


/*Year by Year REVENUE GROWTH*/
select 
year,
FORMAT(REVENUE, 2) AS YEARLY_REVENUE,
FORMAT(LAG(REVENUE) OVER(ORDER BY year), 2) PREVIOUS_YEAR,
FORMAT(REVENUE - LAG(REVENUE) OVER(ORDER BY year), 2) AS YEAR_ON_YEAR_DIFF,
((REVENUE - LAG(REVENUE) OVER(ORDER BY year)) * 100) / REVENUE AS PERCENTAGE_CHANGE
FROM
(
SELECT
year, 
sum(Revenue) AS REVENUE
from nimrodnewdb.bmw
GROUP BY YEAR
)Yearly_sales
ORDER BY YEAR;

/*Regional Analysis*/
SELECT
REGion,
FORMAT(sum(sales_volume), 2) SALES_VOLUME,
FORMAT(sum(revenue), 2) REVENUE
From nimrodnewdb.bmw
GROUP BY region;

SELECT 
region,/*regional fuel type sales analysis*/
fuel_type,
FORMAT(SUM(sales_volume), 2)
FROM nimrodnewdb.bmw
GROUP BY region, Fuel_Type
order by region;

SELECT region,
fuel_type,
rank() over(Partition by region Order by Total_sales) AS FUEL_TYPE_RANK
from
(SELECT 
region,
fuel_type,
FORMAT(SUM(sales_volume), 2) AS TOTAL_SALES
FROM nimrodnewdb.bmw
GROUP BY region, Fuel_Type
order by region)t;

/*checking for the most bought Transmission type*/
SELECT
transmission,
FORMAT(sum(sales_volume), 0) TOTAL_SALES,
FORMAT(sum(revenue), 0) TOTAL_REVENUE
FROM BMW
GROUP BY transmission;

/*REGIONAL TRANSMISSION DEMAND)*/
SELECT 
region,
transmissioN,
Total_sales,
rank() over(partition by region order by Total_revenue) AS DEMAND_RANK
FROM
(SELECT
transmission,
region,
FORMAT(sum(sales_volume), 0) TOTAL_SALES,
FORMAT(sum(revenue), 0) TOTAL_REVENUE
FROM BMW
GROUP BY transmission, region)t
ORDER BY region;

/*Engine size*/
SELECT
DISTINCT engine_size_L
FROM nimrodnewdb.bmw;

/*RANKING eNGINE SIZE SALES*/
SELECT
    FORMAT(count(engine_size_L), 2) AS eNGINE_VOL,
    engine_size,
    rank() OVER (ORDER by count(Engine_Size_L) DESC) AS eNGINE_SALES_RANK
FROM
(SELECT
    Engine_size_L,
     CASE 
			WHEN Engine_size_L <= 2 THEN 'small'
			when Engine_size_L >2 and Engine_size_L <= 3.5 THEN 'medium' 
			ELSE 'BIG'
    end AS ENGINE_SIZE
FROM nimrodnewdb.bmw
)T
GROUP BY engine_size;

/*regional*/ /*ranking Engine size and regional preference*/
SELECT
  region,
  ENGINE_SIZE,
  FORMAT(engine_count, 2) AS ENGINE_VOL,
  RANK() OVER (PARTITION BY region ORDER BY engine_count DESC) AS ENGINE_RANK
FROM (
  SELECT
    region,
    CASE 
      WHEN engine_size_L <= 2 THEN 'small'
      WHEN engine_size_L > 2 AND engine_size_L <= 3.5 THEN 'medium'
      ELSE 'BIG'
    END AS ENGINE_SIZE,
    COUNT(engine_size_L) AS engine_count
  FROM nimrodnewdb.bmw
  GROUP BY region, ENGINE_SIZE
) AS T;


/*YEARLY SALES and revenue*/
SELECT
year,
format(sum(sales_volume), 0) as SALES,
format(SUM(REVENUE), 0) AS REVENUE
FROM nimrodnewdb.bmw
GROUP BY Year
ORDER BY YEAR;