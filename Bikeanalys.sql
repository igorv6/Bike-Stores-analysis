-- The store table contain the store's information like store name and contact information(phone,email,street,city,state and zip_code) --

CREATE TABLE stores (
store_id INT NOT NULL PRIMARY KEY,
store_name VARCHAR (255) NOT NULL,
phone VARCHAR (255),
email VARCHAR (255),
street VARCHAR (255),
city VARCHAR (255),
state VARCHAR (10),
zip_code VARCHAR (5)
);

-- the staff table contain the information about the staff. Staff works at a store specified by the value contain in the store_id column.
-- A staff reports to a store manager specified by the value in the manager_id column. If value in the manager_id is null, then the staff is the top manager.
-- If the staff no longer works in any stores, the value in the active column is set to zero

CREATE TABLE staff (
staff_id INT NOT NULL PRIMARY KEY,
first_name VARCHAR (50) NOT NULL,
last_name VARCHAR (50) NOT NULL,
email VARCHAR (255) NOT NULL UNIQUE,
phone VARCHAR (25),
active TINYINT NOT NULL,
store_id INT NOT NULL,
manager_id INT,
FOREIGN KEY (store_id)
REFERENCES stores (store_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (manager_id) 
REFERENCES staff (staff_id) 
ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Brands table  contains brand's information bike --
CREATE TABLE brands (
brand_id INT NOT NULL PRIMARY KEY,
brand_name VARCHAR (255) NOT NULL
);

-- Categories table contains categories like children bicycles, comfort bicycles and electric bicycles --
CREATE TABLE categories (
category_id INT PRIMARY KEY,
category_name VARCHAR (255) NOT NULL
);

-- production table contain information like name, brand, category, model year and price. Every product belong to a brand specified by the brand_id.
-- A brand may have zero o many products. Each product also belongs a category specified by the category_id column. Each category may have zero or many products
CREATE TABLE product (
product_id INT NOT NULL PRIMARY KEY,
product_name VARCHAR (255) NOT NULL,
brand_id INT NOT NULL,
category_id INT NOT NULL,
model_year INT NOT NULL,
list_price DECIMAL (10,2) NOT NULL,
FOREIGN KEY (category_id)
REFERENCES categories (category_id)
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (brand_id)
REFERENCES brands (brand_id)
ON DELETE CASCADE ON UPDATE CASCADE
);

-- customer table contain information like first name, last name, email, street, city, state and zip code
CREATE TABLE customers (
customer_id INT PRIMARY KEY,
first_name VARCHAR (255) NOT NULL,
last_name VARCHAR (255) NOT NULL,
phone VARCHAR (25),
email VARCHAR (255) NOT NULL,
street VARCHAR (255),
city VARCHAR (50),
state VARCHAR (25),
zip_code VARCHAR (5)
);

-- orders table contain information about the order including customer, order status, order date, required date, shipped date. 
-- contain also information on where the sales transaction was created (store) and who created it (staff).
-- Order status contain number from 1 to 4 1=pending,2=Processing, 3=rejected, 4=completed
CREATE TABLE orders (
order_id INT  PRIMARY KEY,
customer_id INT,
order_status tinyint NOT NULL,
order_date DATE NOT NULL,
required_date DATE NOT NULL,
shipped_date DATE,
store_id INT NOT NULL,
staff_id INT NOT NULL,
FOREIGN KEY (customer_id) 
REFERENCES customers (customer_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (store_id) 
REFERENCES stores (store_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (staff_id) 
REFERENCES staff (staff_id) 
ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Order_details table stores the line items of a sales order. Each line item belongs to a sales order specified by the order_id column.alter.
-- A order_details line item includes product, order quantity, list price and discount
CREATE TABLE order_details (
order_id INT NOT NULL ,
item_id INT NOT NULL ,
product_id INT NOT NULL,
quantity INT NOT NULL,
list_price DECIMAL (10, 2) NOT NULL,
discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
PRIMARY KEY (order_id, item_id),
FOREIGN KEY (order_id) 
REFERENCES orders (order_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (product_id) 
REFERENCES product (product_id) 
ON DELETE CASCADE ON UPDATE CASCADE
);

-- Stocks table store inventory information about the quantity of a particular product in a specific store
CREATE TABLE stocks (
store_id INT NOT NULL,
product_id INT NOT NULL,
quantity INT,
PRIMARY KEY (store_id, product_id),
FOREIGN KEY (store_id) 
REFERENCES stores (store_id) 
ON DELETE CASCADE ON UPDATE CASCADE,
FOREIGN KEY (product_id) 
REFERENCES product (product_id) 
ON DELETE CASCADE ON UPDATE CASCADE
);

-- Before starting our analysis, I proceed creating into the Orders table two new columns that show the day, month and year of when has been placed the order.
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


---------- EXPLORATORY ANALYSIS ----------
-- Generic questions -- 
-- 1) How many store are present?
SELECT  DISTINCT store_name from stores;

-- 2) How many categories of bikes are present?
SELECT DISTINCT category_name FROM categories;

-- 3) What are the  brands  offered from stores
SELECT DISTINCT brand_name FROM brands

---------- SALES ANALYSIS ----------
-- 1) How many orders has been placed during each year? --
SELECT order_year AS year,
COUNT(order_id) as order_received
FROM orders
GROUP BY year
ORDER BY order_received asc;

-- 2) How many quantities has been sold per year?
SELECT order_year as year,
SUM( quantity) as quantity_sold
FROM orders o 
JOIN order_details od
ON o.order_id = od.order_id 
GROUP BY year
ORDER BY quantity_sold;

-- 3) Which store sold most quantity of bikes
SELECT store_name,
sum(quantity) as quantity_sold
FROM stores s
JOIN orders o
ON s.store_id=o.store_id
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY store_name
ORDER BY quantity_sold desc;

-- 4) Quantity of bikes sold by store each year
SELECT store_name,
SUM(quantity) as quantity_sold,
order_year as year
FROM stores s
JOIN orders o
ON s.store_id=o.store_id
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY store_name, year
ORDER BY year desc ;

-- 5) Total revenue for each store
SELECT s.store_id,
s.store_name,
ROUND(SUM(od.quantity * od.list_price * (1 - od.discount )),2) AS total_sales
FROM stores s
JOIN orders o ON s.store_id = o.store_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY s.store_id, s.store_name
ORDER BY total_sales DESC;

-- 6) total revenue store per each year
SELECT store_name,
order_year as year,
ROUND(SUM(od.quantity * od.list_price * (1 - od.discount )),2) as total_revenue
FROM stores s
JOIN orders o
ON s.store_id=o.store_id
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY store_name, year
ORDER BY  year, total_revenue desc;

-- 7) Revenue per month
SELECT order_month as month,
ROUND(SUM(quantity*list_price*(1-od.discount)),2) as total_revenue
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY month
ORDER BY total_revenue desc;

-- 10) Orders received per month
SELECT order_month as month,
SUM(quantity) as quantity_sold
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY month
ORDER BY  quantity_sold desc;

-- 9) Order received per day
SELECT order_day as day,
SUM(quantity) as quantity_sold
FROM orders o
JOIN order_details od
ON o.order_id=od.order_id 
GROUP BY day
ORDER BY  quantity_sold desc;

-- 10) Which person of staff has created more sales transaction in 2018
SELECT first_name,
last_name,
store_name,
COUNT(order_id) as transaction
FROM staff s
JOIN stores st
ON s.store_id=st.store_id
JOIN orders o
ON s.staff_id=o.staff_id
Where order_year=2018 AND active !=0
GROUP BY first_name,last_name,store_name
ORDER BY transaction desc;

---------- PRODUCT ANALYSIS ----------
-- 1) Which brand is the most sold?
SELECT brand_name,
sum(quantity) as quantity_sold
FROM brands b
JOIN product pr
ON b.brand_id=pr.brand_id
JOIN order_details od
ON pr.product_id=od.product_id
GROUP BY brand_name
ORDER BY quantity_sold desc;

-- 2) which categories are the most sold?
SELECT category_name as category,
sum(quantity) as quantity_sold
FROM categories c
JOIN product pr
ON c.category_id=pr.category_id
JOIN order_details od
ON pr.product_id=od.product_id
GROUP BY category
ORDER BY quantity_sold desc;

-- 3) Which product is the most sold?
SELECT product_name as product,
sum(quantity) as quantity_sold
FROM product pr
JOIN order_details od
ON pr.product_id=od.product_id
GROUP BY product
ORDER BY quantity_sold desc;

-- 4) Which 3 products has generated most revenue?
SELECT category_name as category,
product_name as product,
model_year,
ROUND(SUM(quantity*od.list_price*(1-discount)),2) as total_revenue
FROM categories c
JOIN product pr
ON c.category_id=pr.category_id
JOIN order_details od
ON pr.product_id=od.product_id
GROUP BY category,product, model_year
ORDER BY total_revenue desc
LIMIT 3;

---------- CUSTOMER ANALYSIS ----------
-- 1) Which customer has spent more money in the stores
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

-- 2) In what state do most clients live?
SELECT city,
state,
COUNT(*) as number_of_customer
FROM customers
GROUP BY city,state
ORDER BY number_of_customer desc;

 




