SHOW DATABASES;
CREATE DATABASE IF NOT EXISTS Dannys_Diner;
USE Dannys_Diner;

CREATE TABLE IF NOT EXISTS sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  (customer_id, order_date, product_id)
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
  DESCRIBE sales;
  
  CREATE TABLE IF NOT EXISTS menu (
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
  
  CREATE TABLE IF NOT EXISTS members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members
  (customer_id, join_date)
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
  -- CASE STUDY ---------------------------------------------------------------------------------
  /*
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
  */
  
  
-- 1. What is the total amount each customer spent at the restaurant? ---------
SELECT s.customer_id, SUM(m.price) AS amount
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.customer_id;

-- 2. How many days has each customer visited the restaurant? ------------
SELECT customer_id, COUNT(DISTINCT(order_date)) AS num_days
FROM sales 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer? ----------
SELECT s.customer_id, s.order_date, m.product_name
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY s.order_date, m.product_name, s.customer_id
ORDER BY s.order_date;

-- using CTE ---
WITH cte AS (
	SELECT s.customer_id, s.order_date, m.product_name,
	ROW_NUMBER() OVER (PARTITION BY s.customer_id ORDER BY s.order_date) AS row_num
	FROM sales AS s
	INNER JOIN menu AS m
	ON s.product_id = m.product_id
)
SELECT customer_id, product_name, order_date, row_num
FROM cte WHERE row_num = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers? -----
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS num
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name, s.customer_id;

SELECT m.product_name, COUNT(m.product_name) AS no_of_order
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY no_of_order DESC;


-- 5. Which item was the most popular for each customer? ---
SELECT s.customer_id, m.product_name, COUNT(m.product_name) AS no_of_order
FROM sales AS s
INNER JOIN menu AS m
ON s.product_id = m.product_id
GROUP BY m.product_name, s.customer_id;

-- using cte --
WITH cte AS (
	SELECT s.customer_id, m.product_name, COUNT(*) AS order_count,
	DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS d_rank
	FROM sales AS s
	INNER JOIN menu AS m
	ON s.product_id = m.product_id
	GROUP BY s.customer_id, m.product_name
)
SELECT customer_id, product_name, order_count
FROM cte WHERE d_rank = 1;



-- 6. Which item was purchased first by the customer after they became a member? ---
SELECT mb.customer_id, mb.join_date, s.order_date, m.product_name
FROM members AS mb
INNER JOIN sales AS s ON mb.customer_id = s.customer_id
INNER JOIN menu AS m ON s.product_id = m.product_id
WHERE order_date > join_date
ORDER BY mb.customer_id;

-- using cte --
WITH member AS (
SELECT mb.customer_id, mb.join_date, s.order_date, m.product_name,
DENSE_RANK() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date) AS rn
FROM members AS mb
INNER JOIN sales AS s ON mb.customer_id = s.customer_id
INNER JOIN menu AS m ON s.product_id = m.product_id
WHERE order_date > join_date
)
SELECT customer_id, join_date, order_date, product_name
FROM member WHERE rn = 1;



-- 7. Which item was purchased just before the customer became a member? ---
SELECT mb.customer_id, mb.join_date, s.order_date, m.product_name
FROM members AS mb
INNER JOIN sales AS s ON mb.customer_id = s.customer_id
INNER JOIN menu AS m ON s.product_id = m.product_id
WHERE order_date <= join_date
ORDER BY mb.customer_id;

-- using cte ----
WITH member AS (
SELECT mb.customer_id, mb.join_date, s.order_date, m.product_name,
DENSE_RANK() OVER(PARTITION BY mb.customer_id ORDER BY s.order_date DESC) AS rn
FROM members AS mb
INNER JOIN sales AS s ON mb.customer_id = s.customer_id
INNER JOIN menu AS m ON s.product_id = m.product_id
WHERE order_date < join_date
)
SELECT customer_id, join_date, order_date, product_name
FROM member WHERE rn = 1;



-- 8. What is the total items and amount spent for each member before they became a member? -----
SELECT mb.customer_id, COUNT(m.product_name) AS total_items, SUM(m.price) AS total_amount
FROM members AS mb
INNER JOIN sales AS s ON mb.customer_id = s.customer_id
INNER JOIN menu AS m ON s.product_id = m.product_id
WHERE order_date < join_date
GROUP BY mb.customer_id
ORDER BY mb.customer_id;


-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? -----
WITH points_table AS (
	SELECT s.customer_id, m.product_name, m.price,
	(CASE
		WHEN m.product_name = 'sushi' THEN m.price*10*2
		ELSE m.price*10
	END) AS points
	FROM sales AS s
	INNER JOIN menu AS m
	ON s.product_id = m.product_id
)
SELECT customer_id, SUM(points) AS total
FROM points_table
GROUP BY customer_id;



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January? --
WITH cte AS (
	SELECT s.customer_id, m.product_name, m.price, s.order_date, mb.join_date,
	(CASE
		WHEN s.order_date BETWEEN join_date AND DATE_ADD(join_date, INTERVAL 7 DAY) THEN m.price*10*2
		ELSE m.price*10
	END) AS points
	FROM menu AS m  
	INNER JOIN sales AS s ON s.product_id = m.product_id
	INNER JOIN members AS mb ON mb.customer_id = s.customer_id
	WHERE s.order_date < '2021-02-01'
	ORDER BY s.customer_id
) 
SELECT customer_id, SUM(points) AS points
FROM cte 
GROUP BY customer_id ORDER BY points DESC;


-- 11: Determine the name and price of the product ordered by each customer on all order dates & find out whether the customer was a member on the order date or not ----
SELECT s.customer_id, m.product_name, m.price, s.order_date, mb.join_date,
(CASE
	WHEN mb.join_date <= s.order_date THEN 'yes'
	ELSE 'no'
END) AS member
FROM menu AS m  
INNER JOIN sales AS s ON s.product_id = m.product_id
LEFT JOIN members AS mb ON mb.customer_id = s.customer_id;


-- 12. Rank the previous output from Q. 11 based on the order date for each customer. Display NULL if customer was not a member when dish was ordered ----
WITH cte AS(
	SELECT s.customer_id, m.product_name, m.price, s.order_date, mb.join_date,
	(CASE
		WHEN mb.join_date <= s.order_date THEN 'yes'
		ELSE 'no'
	END) AS member_status
	FROM menu AS m  
	INNER JOIN sales AS s ON s.product_id = m.product_id
	LEFT JOIN members AS mb ON mb.customer_id = s.customer_id
)
SELECT * ,
(CASE
	WHEN member_status = 'yes' THEN RANK() OVER(PARTITION BY customer_id, member_status ORDER BY order_date)
    ELSE Null
END) AS ranking
FROM cte;