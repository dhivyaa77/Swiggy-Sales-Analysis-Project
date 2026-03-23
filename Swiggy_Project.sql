create database swiggy_database;
select * from swiggy_database.swiggy_data;
drop table swiggy_database.swiggy_data;
SHOW VARIABLES LIKE 'local_infile';
SHOW VARIABLES LIKE 'pid_file';
SELECT USER();
LOAD DATA LOCAL INFILE 'F:/SQL/Swiggy_Data.csv'
INTO TABLE swiggy_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
CREATE TABLE swiggy_database.swiggy_data (
    State VARCHAR(50),
    City VARCHAR(50),
    Order_Date DATE,
    Restaurant_Name VARCHAR(50),
    Location VARCHAR(50),
    Category VARCHAR(100),
    Dish_Name VARCHAR(255),
    Price DECIMAL(10,2),
    Rating DECIMAL(3,1),
    Rating_Count INT
);


LOAD DATA INFILE 
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Swiggy_Data_Clean.csv'
INTO TABLE swiggy_database.swiggy_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(State, City, @Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price, Rating, Rating_Count)
SET Order_Date = STR_TO_DATE(@Order_Date, '%d-%m-%Y');

select count(*) from swiggy_database.swiggy_data;

select * from swiggy_database.swiggy_data
limit 10;

ALTER TABLE swiggy_database.swiggy_data 
MODIFY Dish_Name TEXT;

ALTER TABLE swiggy_database.swiggy_data
add column Id Int auto_increment PRIMARY KEY;

SELECT * FROM swiggy_database.swiggy_data;

select count(*) from swiggy_database.swiggy_data;

use swiggy_database;

SELECT * FROM swiggy_data;

-- Data validation
-- Null Check
SELECT
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS null_city, 
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS null_order_Date,
    SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS null_Restaurant_Name, 
    SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS null_Location,
    SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS null_dish, 
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_rating, 
    SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM swiggy_database.swiggy_data;

-- Blank or Empty String
SELECT * FROM swiggy_database.swiggy_data
WHERE 
State = "" OR City = "" OR Location = "" OR Category = "" OR Dish_name = "";

SELECT * FROM swiggy_data;

-- Duplication Detection
SELECT 
State, City, Order_Date, Restaurant_Name, Location, 
Category, Dish_Name, Price, Rating, Rating_Count,
count(*) as CNT
FROM swiggy_data
GROUP BY
State, City, Order_Date, Restaurant_Name, Location, 
Category, Dish_Name, Price, Rating, Rating_Count
HAVING 
count(*) > 1;

-- Deleting Duplicates
select count(*) from
(
SELECT *, row_number() OVER (PARTITION BY
State, City, Order_Date, Restaurant_Name, Location, 
Category, Dish_Name, Price, Rating, Rating_Count
ORDER BY (SELECT NULL)
) AS Rn
from swiggy_database.swiggy_data) t
where rn > 1;

DELETE S1 FROM 
swiggy_database.swiggy_data as S1
JOIN
(
SELECT Id from
(
SELECT Id, row_number() OVER (PARTITION BY
State, City, Order_Date, Restaurant_Name, Location, 
Category, Dish_Name, Price, Rating, Rating_Count
ORDER BY (SELECT NULL)
) AS Rn
from swiggy_database.swiggy_data) t
where rn > 1) S2
ON S1.Id = S2.Id;

SELECT COUNT(*) FROM swiggy_database.swiggy_data;

-- CREATING SCHEMA
-- DIMENSION TABLES
-- DATE TABLE
CREATE TABLE swiggy_database.dim_date (
date_id INT auto_increment PRIMARY KEY,
Full_date DATE,
Year INT,
Month INT,
Month_name VARCHAR(20),
Quarter INT,
Day INT,
Week INT
);

-- LOCATION TABLE
CREATE TABLE swiggy_database.dim_location (
location_id INT AUTO_INCREMENT PRIMARY KEY,
State VARCHAR(50),
City VARCHAR(50),
Location VARCHAR(100)
);

-- RESTATURANT TABLE
CREATE TABLE swiggy_database.dim_restaurant (
restaurant_id INT auto_increment PRIMARY KEY,
Restaurant_name VARCHAR(200)
);

-- CATEGORY TABLE
CREATE TABLE swiggy_database.dim_category (
category_id INT auto_increment PRIMARY KEY,
Category VARCHAR(200)
);

-- Dish Table
CREATE TABLE swiggy_database.dim_dish (
dish_id INT auto_increment PRIMARY KEY,
Dish VARCHAR(200)
);

-- FACT TABLE
CREATE TABLE swiggy_database.fact_swiggy (
Order_id INT auto_increment PRIMARY KEY,

date_id INT,
location_id INT,
restaurant_id INT,
category_id INT,
dish_id INT,

Price_INR DECIMAL(10,2),
Rating DECIMAL(4,2),
Rating_count INT,

FOREIGN KEY(date_id) REFERENCES swiggy_database.dim_date(date_id),
FOREIGN KEY(location_id) REFERENCES swiggy_database.dim_location(location_id),
FOREIGN KEY(restaurant_id) REFERENCES swiggy_database.dim_restaurant(restaurant_id),
FOREIGN KEY(category_id) REFERENCES swiggy_database.dim_category(category_id),
FOREIGN KEY(dish_id) REFERENCES swiggy_database.dim_dish(dish_id)
);