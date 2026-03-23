select * from swiggy_database.swiggy_data;

-- INSERT DATA INTO TABLES
-- dim_date
INSERT INTO swiggy_database.dim_date (Full_date, Year, Month, Month_name, Quarter, Day, Week)
	SELECT DISTINCT Order_Date,
    YEAR(Order_Date),
    MONTH(Order_Date),
    MONTHNAME(Order_date),
    QUARTER(Order_date),
    DAY(Order_date),
    WEEK(Order_date)
    FROM swiggy_database.swiggy_data
	WHERE Order_Date IS NOT NULL;
    
SELECT * FROM swiggy_database.dim_location;

-- dim_location
INSERT INTO swiggy_database.dim_location (State, City, Location)
	SELECT DISTINCT State,
    City,
    Location
    FROM swiggy_database.swiggy_data;
    
-- dim_category
INSERT INTO swiggy_database.dim_category (Category)
SELECT DISTINCT Category
FROM swiggy_database.swiggy_data;

SELECT * FROM swiggy_database.dim_category;

-- dim_dish
INSERT INTO swiggy_database.dim_dish (Dish)
SELECT DISTINCT Dish_Name
FROM swiggy_database.swiggy_data;

SELECT * FROM swiggy_database.dim_dish;

-- dim_restaurant
INSERT INTO swiggy_database.dim_restaurant (Restaurant_Name)
SELECT DISTINCT Restaurant_Name
FROM swiggy_database.swiggy_data;

SELECT * FROM swiggy_database.dim_restaurant;

-- Fact Table
INSERT INTO swiggy_database.fact_swiggy
(date_id, location_id, restaurant_id, category_id, dish_id, Price_INR, Rating, Rating_count)

SELECT 
	dd.date_id,
	dl.location_id,
	dr.restaurant_id,
	dc.category_id,
	dsh.dish_id,
	s.Price,
	s.Rating,
	s.Rating_count
FROM swiggy_database.swiggy_data s

JOIN swiggy_database.dim_date dd
ON dd.Full_date = s.Order_date

JOIN swiggy_database.dim_location dl
ON dl.State = s.State
AND dl.City = s.City
AND dl.Location = s.Location

JOIN swiggy_database.dim_restaurant dr
ON dr.Restaurant_Name = s.Restaurant_Name

JOIN swiggy_database.dim_category dc
ON dc.Category = s.Category

JOIN swiggy_database.dim_dish dsh
ON dsh.Dish = s.Dish_Name;

select * from swiggy_database.fact_swiggy;

SELECT * FROM swiggy_database.fact_swiggy f
	JOIN swiggy_database.dim_date d ON f.date_id = d.date_id
    JOIN swiggy_database.dim_location l ON f.location_id = l.location_id
    JOIN swiggy_database.dim_restaurant r on f.restaurant_id = r.restaurant_id
    JOIN swiggy_database.dim_category c on f.category_id = c.category_id
    JOIN swiggy_database.dim_dish ds ON f.dish_id = ds.dish_id;
