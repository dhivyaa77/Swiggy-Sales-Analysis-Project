# 🍊 Swiggy Food Delivery — SQL Data Analysis

> End-to-end SQL analytics on Swiggy food delivery data using a Star Schema Data Warehouse model — uncovering order trends, revenue performance, location insights, and cuisine preferences.

---

## 📌 Project Description

This project performs a comprehensive analysis of Swiggy's food delivery dataset using **MySQL**. The workflow covers the full data lifecycle — from raw ingestion and cleaning, through dimensional modelling, to business intelligence queries and actionable insights.

A **Star Schema** data warehouse is designed and built from scratch, enabling efficient multi-dimensional querying across time, location, restaurant, category, and dish dimensions.

---

## 🎯 Business Problem

Food delivery platforms generate massive transactional data daily. This project answers critical business questions such as:

- Which **cities and states** generate the most orders and revenue?
- Which **restaurants and dishes** are most popular?
- How do **revenue trends** vary across months, quarters, and weekdays?
- What are **customer rating patterns** across different cuisines?
- How is **pricing distributed** across the order base?

---

## 📂 Dataset Overview

| Column | Description |
|---|---|
| `Order_Date` | Date the order was placed |
| `State` | State where the order was placed |
| `City` | City where the order was placed |
| `Restaurant_Name` | Name of the restaurant |
| `Category` | Food category / cuisine type |
| `Dish_Name` | Name of the dish ordered |
| `Price` | Price of the dish (INR) |
| `Rating` | Customer rating |
| `Rating_Count` | Number of ratings received |

---

## 🧹 Data Cleaning

The following data quality steps were applied before analysis:

1. **NULL Value Check** — Identified missing values across all columns
2. **Blank / Empty String Detection** — Flagged rows with empty State, City, Category, or Dish fields
3. **Duplicate Detection** — Used `GROUP BY` + `HAVING COUNT(*) > 1` to find duplicate records
4. **Duplicate Removal** — Applied `ROW_NUMBER()` window function partitioned by key columns; deleted all rows where `Rn > 1`
5. **Standardization** — Prepared clean data for dimensional model loading

---

## 🏗️ Data Warehouse Design — Star Schema

A **Star Schema** model was designed to optimise analytical query performance.

```
                    ┌─────────────┐
                    │  dim_date   │
                    │─────────────│
                    │ date_id  PK │
                    │ Full_date   │
                    │ Year        │
                    │ Month       │
                    │ Quarter     │
                    │ Week        │
                    └──────┬──────┘
                           │
┌──────────────┐    ┌──────▼───────┐    ┌─────────────────┐
│ dim_location │    │ fact_swiggy  │    │  dim_restaurant  │
│──────────────│    │──────────────│    │─────────────────│
│location_id PK│◄───│ order_id  PK │───►│restaurant_id PK │
│ State        │    │ date_id   FK │    │ Restaurant_name  │
│ City         │    │location_id FK│    └─────────────────┘
│ Location     │    │restaurant_idFK│
└──────────────┘    │category_id FK│    ┌─────────────────┐
                    │ dish_id    FK│───►│  dim_category   │
┌──────────────┐    │ Price_INR    │    │─────────────────│
│  dim_dish    │    │ Rating       │    │ category_id  PK │
│──────────────│    │ Rating_count │    │ Category        │
│ dish_id   PK │◄───│              │    └─────────────────┘
│ Dish         │    └──────────────┘
└──────────────┘
```

### Dimension Tables
| Table | Primary Key | Description |
|---|---|---|
| `dim_date` | `date_id` | Date attributes — Year, Month, Quarter, Week |
| `dim_location` | `location_id` | Geographic hierarchy — State, City, Location |
| `dim_restaurant` | `restaurant_id` | Restaurant names |
| `dim_category` | `category_id` | Food/cuisine categories |
| `dim_dish` | `dish_id` | Individual dish names |

### Fact Table
| Table | Description |
|---|---|
| `fact_swiggy` | Stores transactional order records with FKs to all dimension tables plus Price, Rating, and Rating_Count measures |

---

## 📊 KPIs & Analysis Performed

### Basic KPIs
| Metric | Result |
|---|---|
| Total Orders | Computed via `COUNT(*)` |
| Total Revenue | **53.00 INR Million** |
| Average Dish Price | Computed via `AVG(Price_INR)` |
| Average Rating | Computed via `ROUND(AVG(Rating), 2)` |

### Time-Series Analysis
- **Monthly Orders & Revenue** — Trends across months within each year
- **Quarterly Orders & Revenue** — Quarter-wise performance comparison
- **Year-wise Order Growth** — Annual order volume tracking
- **Day-of-Week Revenue** — Revenue breakdown by weekday vs weekend

### Location Analysis
- Top 10 Cities by Order Volume
- Bottom 10 Cities by Order Volume
- Top 10 Cities by Revenue
- State-wise Revenue Contribution

### Food & Restaurant Performance
- Top 10 Restaurants by Orders
- Top 10 Food Categories by Orders
- Most Ordered Dishes (Top 10)
- Cuisine Performance — Orders + Average Rating combined

### Pricing Intelligence
- Order Volume segmented by Price Range buckets:
  - Under ₹100 / ₹100–199 / ₹200–299 / ₹300–499 / ₹500+

---

## 💡 Key Business Insights

| # | Insight |
|---|---|
| 1 | 📈 Orders **peak in January, May, and August** — start-of-year demand surge observed |
| 2 | 🗓️ **Q2 leads** in both order volume and revenue across all years |
| 3 | 📅 **Weekends (Sat & Sun)** generate the highest daily orders and revenue |
| 4 | 🏙️ **Top 10 cities** drive a disproportionate share of total revenue |
| 5 | 💲 The **₹100–299 price band** captures the majority of orders — value-conscious customer base |
| 6 | 🍛 Certain cuisine categories achieve both **high order volume and high ratings** simultaneously |

---

## 🛠️ Tech Stack

| Tool | Usage |
|---|---|
| **MySQL 8.0** | Primary database & query engine |
| **Star Schema** | Data warehouse design pattern |
| **Window Functions** | `ROW_NUMBER()` for deduplication |
| **CTEs & Subqueries** | Complex query structuring |
| **Multi-table JOINs** | Cross-dimensional analysis |
| **Aggregate Functions** | `SUM`, `AVG`, `COUNT`, `ROUND` |
| **Date Functions** | `YEAR()`, `MONTH()`, `DAYNAME()`, `DATE_FORMAT()` |
| **CASE WHEN** | Price range bucketing logic |

---

## 📁 Repository Structure

```
swiggy-sql-analysis/
│
├── data/
│   └── swiggy_data.csv          # Raw dataset
│
├── sql/
│   ├── 01_data_cleaning.sql     # NULL checks, deduplication
│   ├── 02_schema_creation.sql   # CREATE TABLE statements (dims + fact)
│   ├── 03_etl_load.sql          # INSERT INTO dimension & fact tables
│   ├── 04_kpis.sql              # Basic KPI queries
│   ├── 05_time_analysis.sql     # Monthly, quarterly, weekly trends
│   ├── 06_location_analysis.sql # City & state performance
│   ├── 07_food_analysis.sql     # Restaurant, category & dish queries
│   └── 08_pricing_analysis.sql  # Price range segmentation
│
├── portfolio/
│   └── index.html               # Interactive portfolio page
│
└── README.md
```

---

## 🚀 How to Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/swiggy-sql-analysis.git
   cd swiggy-sql-analysis
   ```

2. **Set up the database**
   ```sql
   CREATE DATABASE swiggy_database;
   USE swiggy_database;
   ```

3. **Import raw data**
   ```sql
   -- Import swiggy_data.csv into swiggy_database.swiggy_data table
   -- using MySQL Workbench Table Data Import Wizard or LOAD DATA INFILE
   ```

4. **Run SQL files in order**
   ```bash
   01_data_cleaning.sql
   02_schema_creation.sql
   03_etl_load.sql
   04_kpis.sql  →  08_pricing_analysis.sql
   ```

---

## 📬 Connect

If you found this project useful or have feedback, feel free to connect!

- 🔗 [LinkedIn](https://linkedin.com)
- 💻 [GitHub](https://github.com)

---

*Built with MySQL · Star Schema · Data Warehouse Design*
