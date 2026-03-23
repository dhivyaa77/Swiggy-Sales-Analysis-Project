SELECT * FROM swiggy_database.fact_swiggy;

-- Basic KPI's
-- Total Orders
SELECT COUNT(*) AS Total_orders
from swiggy_database.fact_swiggy;

-- Total Revenue (INR Million)
SELECT SUM(Price_INR) as Total_Revenue
FROM swiggy_database.fact_swiggy; -- 53002984.47 Convert into INR values

SELECT
CONCAT(
	FORMAT(SUM(CAST(Price_INR AS DECIMAL(10,2))) / 1000000, 2), 
    ' INR Millions'
    ) AS Total_Revenue
FROM swiggy_database.fact_swiggy;

-- Average Dish Price
SELECT
CONCAT(
	FORMAT(AVG(CAST(Price_INR AS DECIMAL(10,2))), 2), 
    ' INR'
    ) AS Average_Dish_Price
FROM swiggy_database.fact_swiggy;

-- Average Rating
SELECT ROUND(AVG(Rating), 2) as Average_Rating
FROM swiggy_database.fact_swiggy;

-- Deep-dive in Business Analysis
-- Monthly Total Orders
SELECT
	d.Year, d.Month, d.Month_name,
	COUNT(*) AS Total_Orders
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year, d.Month, d.Month_name
ORDER BY
Count(*) DESC;

-- Monthly Trends
SELECT
	d.Year, d.Month, d.Month_name,
	SUM(Price_INR) AS Total_Revenue
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year, d.Month, d.Month_name
ORDER BY SUM(Price_INR) DESC;

-- Quaterly order
SELECT
	d.Year, d.Quarter,
    COUNT(*) AS Quarterly_Orders
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year, d.Quarter
ORDER BY
COUNT(*) desc;

-- Quarterly Trends
SELECT
	d.Year, d.Quarter,
    SUM(f.Price_INR) AS Quarterly_Revenue
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year, d.Quarter
ORDER BY
SUM(f.Price_INR) desc;

-- Year-wise growth
SELECT
	d.Year,
    COUNT(*) AS Yearly_total_Orders
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year
ORDER BY
COUNT(*) DESC;

SELECT
	d.Year,
    SUM(f.Price_INR) AS Yearly_Revenue
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY
d.Year
ORDER BY
SUM(f.Price_INR) DESC;

-- Orders by Week days
SELECT
	DAYNAME(d.Full_date) as Week_Day, DATE_FORMAT(d.Full_date, '%w') as Week_No,
    Count(*) as week_orders
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY 
DAYNAME(d.Full_date), DATE_FORMAT(d.Full_date, '%w')
ORDER BY DATE_FORMAT(d.Full_date, '%w');

SELECT
	DAYNAME(d.Full_date) as Week_Day,  DATE_FORMAT(d.Full_date, '%w') as Week_No,
    SUM(f.Price_INR) as weekly_Revenue
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_date d ON
f.date_id = d.date_id
GROUP BY 
DAYNAME(d.Full_date), DATE_FORMAT(d.Full_date, '%w')
ORDER BY weekly_Revenue DESC;

-- Location Base Analysis
-- Top 10 cities by Order volumns
SELECT dl.City as City,
	count(*) as Highest_Orders
FROM swiggy_database.fact_swiggy f
JOIN swiggy_database.dim_location dl ON
f.location_id = dl.location_id
	GROUP BY dl.City
    ORDER BY COUNT(*) DESC
LIMIT 10;

-- Least 10 cities by Orders
SELECT dl.City as City,
	COUNT(*) AS Lowest_Orders
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_location dl ON
fs.location_id = dl.location_id
	GROUP BY dl.city
    ORDER BY COUNT(*) ASC
limit 10;

-- Top 10 Cities Revenue
SELECT dl.City as City,
	SUM(fs.Price_INR) as Highest_Revenue
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_location dl ON
fs.location_id = dl.location_id
	GROUP BY dl.city
    ORDER BY SUM(fs.Price_INR) desc
limit 10;

-- Revenue contributed by States
SELECT dl.State as State,
	SUM(fs.Price_INR) as Total_Revenue
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_location dl ON
fs.location_id = dl.location_id
	GROUP BY dl.State
    ORDER BY SUM(fs.Price_INR) desc;

-- Food Performance
-- Top 10 Restaurant by Orders
SELECT dr.Restaurant_Name as Restaurant,
	COUNT(*) AS Total_Orders
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_restaurant dr ON
fs.restaurant_id = dr.restaurant_id
	GROUP BY dr.Restaurant_name
    ORDER BY COUNT(*) DESC
LIMIT 10;

-- Top 10 Categores by Orders
SELECT c.Category as Category,
	COUNT(*) AS Total_Orders
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_category c ON
fs.category_id = c.category_id
	GROUP BY c.Category
    ORDER BY COUNT(*) DESC
LIMIT 10;

-- Most Order Dish
SELECT ds.Dish,
	COUNT(*) AS Order_counts
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_dish ds ON
fs.dish_id = ds.dish_id
GROUP BY ds.Dish
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Cuisine Performance (Orders + Avg Rating)
SELECT c.Category as Category,
	COUNT(*) AS Total_Orders,
    round(Avg(fs.Rating), 2) as Avg_Rating
FROM swiggy_database.fact_swiggy fs
JOIN swiggy_database.dim_category c ON
fs.category_id = c.category_id
	GROUP BY c.Category
ORDER BY Total_Orders DESC;

-- Total Order by Price Range
SELECT
	CASE
		WHEN Price_INR < 100 THEN 'Under 100'
        WHEN Price_INR BETWEEN 100 AND 199 THEN '100-199'
        WHEN Price_INR BETWEEN 200 AND 299 THEN '200-299'
        WHEN Price_INR BETWEEN 300 AND 499 THEN '300-499'
        ELSE '500+'
	END AS Price_range,
    COUNT(*) AS Total_orders
FROM swiggy_database.fact_swiggy
group by 
	Price_range
ORDER BY Total_orders DESC;
        