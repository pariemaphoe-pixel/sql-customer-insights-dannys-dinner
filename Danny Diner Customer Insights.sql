-- Databricks notebook source

CREATE TABLE IF NOT EXISTS  sales(
  customer_id varchar(5),
  order_date date,
  product_id int);
  INSERT INTO sales(
   customer_id, order_date,product_id)
   VALUES
   ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');


  CREATE TABLE IF NOT EXISTS menu  (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);


INSERT INTO menu
  (product_id, product_name, price)
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');

-- COMMAND ----------

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);


INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

-- COMMAND ----------

SELECT s.customer_id,Sum(m.price)
 FROM sales s
 LEFT JOIN menu m
 ON s.product_id=m.product_id
 GROUP BY s.customer_id;

-- COMMAND ----------

---How many days has each customer visited the restaurant?
SELECT customer_id,COUNT(order_date)
FROM sales
GROUP BY customer_id;

-- COMMAND ----------

---What was the first item from the menu purchased by each customer?
 SELECT m.product_name,s.customer_id
 FROM menu m
 INNER JOIN sales s
 ON m.product_id=s.product_id
 WHERE order_date = '2021-01-01'
 GROUP BY m.product_name,s.customer_id;

-- COMMAND ----------

---What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT m.product_name,COUNT(s.product_id ) AS count_purchased
 FROM menu m
 INNER JOIN sales s
 ON m.product_id=s.product_id
 GROUP BY m.product_name
 ORDER BY count_purchased DESC
 LIMIT 1;

-- COMMAND ----------

---Which item was the most popular for each customer?
SELECT m.product_name,s.Customer_id,Count(s.product_id)as most_popular_item
FROM menu m
INNER JOIN sales s
ON m.product_id=s.product_id
GROUP BY m.product_name,s.Customer_id
ORDER BY most_popular_item DESC
LIMIT 3;

WITH popular_items AS(SELECT
                           s.customer_id,m.product_name,count(s.product_id)AS order_count,
                           DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(s.product_id)DESC) as rank
                           FROM sales s
                           JOIN menu m ON s.product_id = m.product_id
                           GROUP BY s.customer_id, m.product_name
)
SELECT 
   customer_id,product_name,order_count
   FROM popular_items 
   WHERE rank =1;
