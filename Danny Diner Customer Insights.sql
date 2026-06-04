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
