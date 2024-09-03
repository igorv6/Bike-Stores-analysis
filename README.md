# Bike-Stores-analysis
Bike stores analysis using SQL and Power BI

### Project Overview
Bike stores analysis using MySQL and Power BI
This data analysis project aims to provide insights into the performance of 3 different Bike Store. By analyzing various aspects of the sales data,we seek to identify trends, recommendations and gain a deeper understanding of the stores' performance.


![image](https://github.com/user-attachments/assets/97145b6d-259d-4f0d-8c9f-bfa6070847fd)


### Data Sources
Bike Stores Data: the Datasets used for this analysis has been provide from Kaggle https://www.kaggle.com/datasets/dillonmyrick/bike-store-sample-database

### Tools
- MySql - Data Exploring and Analysis
- Power Bi - Data Visualization

### Prepare and Process Phase
In the initial data preparation phase, I performed the following task:
1. Downloading the CSV files from Kaggle
2. Loading files on MySql and creating tables
3. Handling missing/Null values.

### Exploratory Data Analysis
My Exploratory Data Analysis involved exploring the Bike stores data to answer to the key questions, such as:
- What is the overall sales trend?
- Which stores sold most product?
- Which store made more revenue?
- Which category was the best-selling?
- Which product was the best-selling?

### Data Analysis
Include some interesting code/features worked with.

Adding year,month and day:

```sql
-- 1) 
SELECT * FROM orders;
-- 2)
SELECT order_date,
DAYNAME(order_date)
FROM orders;
-- 3)
ALTER TABLE orders ADD COLUMN order_day VARCHAR (25);
-- 4)
UPDATE orders SET order_day = DAYNAME(order_date);
-- 5)
SELECT order_date,
MONTHNAME(order_date)
FROM orders;
-- 6)
ALTER TABLE orders ADD COLUMN order_month VARCHAR (25);
-- 7)
UPDATE orders SET order_month=MONTHNAME(order_date);
-- 8)
SELECT order_date,
YEAR(order_date)
FROM orders;
-- 9)
ALTER TABLE orders ADD COLUMN order_year INT;
-- 10)
UPDATE orders SET order_year=YEAR(order_date);
```

Calculating revenue for each store:

```sql
SELECT s.store_id,
s.store_name,
ROUND(SUM(od.quantity * od.list_price * (1 - od.discount )),2) AS total_sales
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY s.store_id, s.store_name
ORDER BY total_sales DESC;
```

Calculating which customer has spent more money in the stores

```sql
SELECT first_name,
last_name,
email,
street,
city,
state,
ROUND(SUM(quantity*list_price*(1-discount)),2) as money_spent
FROM customers c
JOIN orders o
ON c.customer_id=o.customer_id
JOIN order_details od
ON o.order_id=od.order_id
GROUP BY first_name, last_name, email,street,city,state
ORDER BY money_spent desc
LIMIT 1;
```

### Results/Findings
The analysis results are summaried as follows:
1. In our analysis comparing the years 2016-2017-2018, we can see that starting from 2016 we can see growth in quantity sold and revenue in 2017. But during 2018 we have a serious drop in quantities sold and lower revenues even than the year 2016.
2. Analyzing the total revenue and quantity sold for each store, we can see that during all the three years Baldwin Bikes is the stores with most revenue and quantity sold during each year followed by Santa Cruz Bikes and then Rowlett Bikes.
3. The brand most sold during all these three years has is Elektra, the most categories choosen from customer is Cruisers Bicycles while the product most sold during the 2018 is 'Electra Cruiser 1 (24-Inch) - 2016'with 296 unit sold.Considering all these three years the top 3 product that have genereted most revenue are: Trek Slash 8 27.5, Trek Fuel Ex 8 29, Trek Conduit.
4. Most of the customer lives in NY that is the same state of the store Baldwin Bikes which has the most quantity sold comparing with the others. The customer who has spent more money is Sharyn Hopkins from Baldwinsville NY with a total spent of 34807,94 USD at Baldwin Bikes store.

### Recommendations
Based on the analysis, the huge drop in sales and revenue for the three stores in 2018 needs urgent extensive analysis. inclluding other stores and analyzing the entire bicycle market to see if the trend is the same. Santa Cruz Bikes and Rowleet need to improve their attraction to customers. An analysis of their marketing activities is needed to see and implement new strategies for engagement with customers.
Analyzing the products, the most sold product for each years is the Electra Amsterdam Bike, the three stores have to continue offering the Electra brand. While they should decide if keep to sell the brand whith less quantity sold and decide if is better replace them with another brand. Lastly,  the customers' favorite category is Cruisers this means that for 2016-2017-2018, customers want to ride a bike designed primarily for comfort and recreational use. 

