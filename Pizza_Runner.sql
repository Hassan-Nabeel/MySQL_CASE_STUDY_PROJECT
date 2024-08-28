SHOW DATABASES;
CREATE SCHEMA IF NOT EXISTS pizza_runner;
USE pizza_runner;

CREATE TABLE IF NOT EXISTS runners (
  runner_id INT,
  registration_date DATE 
  );
INSERT INTO runners (runner_id, registration_date)
VALUES (1, '2021-01-01'),
	   (2, '2021-01-03'),
	   (3, '2021-01-08'),
       (4, '2021-01-15');
       
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);
INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');
  
DESCRIBE customer_orders;
  
CREATE TABLE runner_orders (
	  order_id INTEGER,
	  runner_id INTEGER,
	  pickup_time VARCHAR(19),
	  distance VARCHAR(7),
	  duration VARCHAR(10),
	  cancellation VARCHAR(23)
);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
CREATE TABLE pizza_names (
	  pizza_id INTEGER,
	  pizza_name TEXT 
);      
INSERT INTO pizza_names (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');
  
CREATE TABLE pizza_recipes (
	  pizza_id INTEGER,
	  toppings TEXT 
);
INSERT INTO pizza_recipes (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');

CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT 
);  
INSERT INTO pizza_toppings (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  
  -- DATA CLEANING ---------------------------------------------------------------------------
  -- Make it NULL where the string 'null' or blank entries appear ------
UPDATE Customer_orders
SET extras = NULL 
WHERE extras = 'null' or extras = '' ;
  
UPDATE Customer_orders
SET exclusions = NULL 
WHERE exclusions IN ( 'null' , '') ;

-- From km and min remove the string and keep them in numeric since all are the same value ------
UPDATE runner_orders
SET distance = TRIM(REPLACE(distance,'km',''));

UPDATE runner_orders
SET distance = NULL 
WHERE distance = 'null';
 
UPDATE runner_orders
SET pickup_time = NULL 
WHERE pickup_time = 'null';

UPDATE runner_orders
SET cancellation = NULL 
WHERE cancellation IN ( 'null' , '') ;

-- Update the duration column, remove the text part & any extra spaces and update the 'null' to NULL -----
-- UPDATE runner_orders
-- SET duration =  SUBSTRING(duration, 1, 2)
-- WHERE duration != 'null';

UPDATE runner_orders
SET duration = TRIM(REGEXP_REPLACE(duration, '[^0-9]', ''))		-- reg_ex to replace any character which is not digit into empty string ---
WHERE duration != 'null';

UPDATE runner_orders
SET duration = NULL 
WHERE duration = 'null';

-- Converting data type of distance column to deciaml ----------
ALTER TABLE runner_orders
MODIFY COLUMN distance DECIMAL(4,2);

-- Converting the duration and pickup column in integer ------
ALTER TABLE runner_orders
MODIFY COLUMN duration INT;

ALTER TABLE runner_orders
MODIFY COLUMN pickup_time TIMESTAMP;

DESCRIBE runner_orders;



-- PART 1: PIZZA METRIC ----------
-- 1. How many pizzas were ordered? ---
SELECT COUNT(pizza_id) AS total_order FROM customer_orders;
  
-- 2. How many unique customer orders were made? ---
SELECT COUNT(DISTINCT(order_id)) AS unique_customers FROM customer_orders;

-- 3. How many successful orders were delivered by each runner? ---
SELECT  runner_id, COUNT(order_id) AS no_of_order FROM runner_orders
WHERE cancellation IS NULL 
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered? ---
SELECT co.pizza_id, pn.pizza_name, COUNT(co.order_id) AS delivered 
FROM runner_orders AS ro  
INNER JOIN customer_orders AS co  ON ro.order_id = co.order_id 
INNER JOIN pizza_names AS pn      ON pn.pizza_id = co.pizza_id
WHERE ro.cancellation IS NULL
GROUP BY co.pizza_id, pn.pizza_name;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer? ---
SELECT co.customer_id, pn.pizza_name, COUNT(co.pizza_id) AS num_order 
FROM customer_orders AS co
LEFT JOIN pizza_names AS pn
ON pn.pizza_id = co.pizza_id
GROUP BY co.customer_id, pn.pizza_name
ORDER BY co.customer_id ;
  
-- 6. What was the maximum number of pizzas delivered in a single order? --
SELECT co.order_id, COUNT(co.order_id) AS pizza_per_delivery
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON ro.order_id = co.order_id 
WHERE ro.cancellation IS NULL
GROUP BY co.order_id
ORDER BY pizza_per_delivery DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes? ---
SELECT co.customer_id, COUNT(co.pizza_id) AS pizzas_delivered,
SUM(CASE
	WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL 
    THEN 1 ELSE 0
    END ) atleast1_change, 
SUM(CASE
	WHEN co.exclusions IS NULL AND co.extras IS NULL 
    THEN 1 ELSE 0
    END ) no_change
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id 
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;


-- using cte ---
WITH cte AS (
	SELECT co.customer_id, co.exclusions, co.extras,  COUNT(co.customer_id) AS num
	FROM customer_orders AS co
    INNER JOIN runner_orders AS ro
	ON co.order_id = ro.order_id 
	WHERE ro.cancellation IS NULL
	GROUP BY co.customer_id, co.exclusions, co.extras
)
SELECT customer_id, exclusions, extras, num
FROM cte
WHERE exclusions IS NOT NULL OR extras IS NOT NULL;
-- WHERE exclusions IS NULL AND extras IS NULL;
-- GROUP BY order_id, exclusions, extras;



-- 8. How many pizzas were delivered that had both exclusions and extras? --
SELECT co.customer_id, COUNT(co.pizza_id) AS pizzas_delivered,
SUM(CASE
	WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL 
    THEN 1 ELSE 0
    END ) AS both_exclusion_extras
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id 
WHERE ro.cancellation IS NULL
GROUP BY co.customer_id;


-- 9 . What was the total volume of pizzas ordered for each hour of the day? --
SELECT DISTINCT(order_time),  HOUR(order_time) AS hr,
COUNT(pizza_id) OVER(PARTITION BY DATE(order_time) ORDER BY order_time ) AS pizza_per_hr
FROM customer_orders;
-- GROUP BY order_time
-- ORDER BY order_time ;

-- Another method ---
SELECT HOUR(order_time) AS hr, COUNT(Order_id) AS pizza_volume
FROM customer_orders
GROUP BY hr;


-- 10. What was the volume of orders for each day of the week? --
SELECT DAYNAME(order_time) AS week_day, COUNT(Order_id) AS pizza_volume
FROM customer_orders
GROUP BY week_day;



 -- B. Runner and Customer Experience ---------------------------------------------------
 -- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01) ----
 SELECT  WEEK(registration_date) AS reg_week, COUNT(DISTINCT runner_id) AS no_of_runner 
 FROM runners
 GROUP BY  WEEK(registration_date);

-- using YEARWEEK function ---
SELECT 
FLOOR((DATEDIFF(registration_date, '2021-01-01') / 7)) + 1 AS reg_week,
COUNT(runner_id) AS no_of_runners
FROM runners
GROUP BY reg_week
ORDER BY reg_week;


 
 -- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order? ---
WITH cte AS (
	 SELECT co.order_id, co.order_time, ro.pickup_time, ro.runner_id, TIMEDIFF(ro.pickup_time, co.order_time) AS avg_time
	 FROM customer_orders AS co
	 INNER JOIN runner_orders AS ro
	 ON co.order_id = ro.order_id
)
SELECT runner_id, AVG(MINUTE(avg_time)) AS avg_tm_of_runner
FROM cte
GROUP BY runner_id;

-- 
SELECT ro.runner_id, AVG(MINUTE(TIMEDIFF(ro.pickup_time, co.order_time))) AS avg_time
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id
GROUP BY ro.runner_id;
      
-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare? ---
-- (order_id, pizza count in each order, time taken between each order and pick up) ----
WITH cte AS(
	SELECT co.order_id, ro.runner_id, COUNT(co.pizza_id) AS no_pizzas_delivered, MINUTE(TIMEDIFF(ro.pickup_time, co.order_time)) AS time_taken_min
	FROM customer_orders AS co
	INNER JOIN runner_orders AS ro
	ON co.order_id = ro.order_id
	WHERE ro.cancellation IS NULL
	GROUP BY co.order_id, ro.runner_id, time_taken_min
)
SELECT no_pizzas_delivered, AVG(time_taken_min) AS avg_time_per_pizza
FROM cte
GROUP BY no_pizzas_delivered;

---- Insight/Realtionship (more pizza per order requies more time for preparation ) 


-- 4. What was the average distance travelled for each customer? ----
SELECT co.customer_id, ROUND(AVG(ro.distance), 2) AS avg_distance_km
FROM customer_orders AS co
INNER JOIN runner_orders AS ro
ON co.order_id = ro.order_id
GROUP BY co.customer_id ;


-- 5. What was the difference between the longest and shortest delivery times for all orders? ------
SELECT MAX(duration) - MIN(duration) AS diff_of_longest_shortest_order_min
FROM runner_orders
WHERE cancellation IS NULL ;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values? -----
-- avg speed of runner with their customer id ---
SELECT order_id, runner_id, SUM(distance) AS km, ROUND(AVG(distance / duration)*60, 2) AS avg_speed_km_per_hr
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY order_id, runner_id;

-- avg speed of customer with their toal km ----
SELECT runner_id, SUM(distance) AS total_km, ROUND(AVG(distance / duration)*60, 2) AS avg_speed_km_per_hr
FROM runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- Trend/Insight (runner with greater distance has greater speed than lower distance runner)

-- 7. What is the successful delivery percentage for each runner? ----
SELECT runner_id, COUNT(order_id) AS total_order, COUNT(cancellation) AS order_cancelled, 
ROUND((COUNT(order_id) - COUNT(cancellation))/COUNT(order_id)*100, 2) AS successfull_delivery_percentage 
FROM runner_orders
GROUP BY runner_id;

