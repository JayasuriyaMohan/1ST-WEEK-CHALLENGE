  create database dannys_dinner;
use dannys_dinner;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');
  select * from runners
  
  CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id,pizza_id, exclusions, extras, order_time)
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
  
  clean the table:
  
  CREATE TABLE dannys_dinner.customer_orders_new (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

insert into dannys_dinner.customer_orders_new SELECT order_id, customer_id, pizza_id, 
  CASE 
    WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
    ELSE exclusions
    END AS exclusions,
  CASE 
    WHEN extras IS NULL or extras LIKE 'null' THEN ' '
    ELSE extras 
    END AS extras, 
  order_time
FROM dannys_dinner.customer_orders;


CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
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
  
  clean the table:
  
  
CREATE TABLE dannys_dinner.runner_orders_new (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

insert into dannys_dinner.runner_orders_new select order_id, runner_id,
  CASE 
    WHEN pickup_time LIKE 'null' THEN ' '
    ELSE pickup_time 
    END AS pickup_time,
  CASE 
    WHEN distance LIKE 'null' THEN ' '
    WHEN distance LIKE '%km' THEN TRIM('km' from distance) 
    ELSE distance END AS distance,
  CASE 
    WHEN duration LIKE 'null' THEN ' ' 
    WHEN duration LIKE '%mins' THEN TRIM('mins' from duration) 
    WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)        
    WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)       
    ELSE duration END AS duration,
  CASE 
    WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ''
    ELSE cancellation END AS cancellation
FROM dannys_dinner.runner_orders;

  
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');
  
  select * from pizza_recipes;
  
  CREATE TABLE pizza_recipes_new (
  pizza_id INTEGER,
  topping_id TEXT);
  
  INSERT INTO pizza_recipes_new 
  (pizza_id, topping_id)
  values
  (1,1),
  (1,2),
  (1,3),
  (1,4),
  (1,5),
  (1,6),
  (1,8),

  (2,4),
  (2,6),
  (2,7),
  (2,9),
  (2,11),
  (2,12);
  
  ALTER TABLE pizza_recipes_new 
RENAME COLUMN toppings_id TO topping_id;
  

  


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
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
  
  ------------------------------------------------------------------------
  A.PIZZA METRICS
  
  1.How many pizzas were ordered?
SELECT COUNT(*) AS pizza_order_count
FROM customer_orders_NEW;
  
  2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS unique_order_count
FROM customer_orders_new;
  
  3. How many successful orders were delivered by each runner?

SELECT runner_id, COUNT(order_id) AS successful_orders
FROM runner_orders_new
WHERE distance != 0
GROUP BY runner_id;

4. How many of each type of pizza was delivered?

SELECT p.pizza_name, COUNT(c.pizza_id) AS delivered_pizza_count
FROM customer_orders_new AS c
JOIN runner_orders_new AS r
 ON c.order_id = r.order_id
JOIN pizza_names AS p
 ON c.pizza_id = p.pizza_id
WHERE r.distance != 0
GROUP BY p.pizza_name;

5.How many Vegetarian and Meatlovers were ordered by each customer?

SELECT c.customer_id, p.pizza_name, COUNT(p.pizza_name) AS order_count
FROM customer_orders_new AS c
JOIN pizza_names AS p
 ON c.pizza_id= p.pizza_id
GROUP BY c.customer_id, p.pizza_name
ORDER BY c.customer_id;

6. What was the maximum number of pizzas delivered in a single order?

WITH pizza_count AS
(
 SELECT c.order_id, COUNT(c.pizza_id) AS pizza_per_order
 FROM customer_orders_new AS c
 JOIN runner_orders_new AS r
  ON c.order_id = r.order_id
 WHERE r.distance != 0
 GROUP BY c.order_id
)

SELECT MAX(pizza_per_order) AS pizza_count
FROM pizza_count;

7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT c.customer_id,
 SUM(CASE 
  WHEN c.exclusions <> ' ' OR c.extras <> ' ' THEN 1
  ELSE 0
  END) AS at_least_1,
 SUM(CASE 
  WHEN c.exclusions = ' ' AND c.extras = ' ' THEN 1 
  ELSE 0
  END) AS no_change
FROM customer_orders_new AS c
JOIN runner_orders_new AS r
 ON c.order_id = r.order_id
WHERE r.distance != 0
GROUP BY c.customer_id
ORDER BY c.customer_id;

8. How many pizzas were delivered that had both exclusions and extras?

SELECT  
 SUM(CASE
  WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1
  ELSE 0
  END) AS pizza_count_w_exclusions_extras
FROM customer_orders_new AS c
JOIN runner_orders_new AS r
 ON c.order_id = r.order_id
WHERE r.distance >= 1 
 AND exclusions <> ' ' 
 AND extras <> ' ';
 
 9. What was the total volume of pizzas ordered for each hour of the day?

SELECT HOUR(order_time) AS hour_of_day, 
 COUNT(order_id) AS pizza_count
FROM customer_orders_new
GROUP BY HOUR(order_time);

10. What was the volume of orders for each day of the week?

SELECT dayname(order_time) AS day_of_week, 
 COUNT(order_id) AS total_pizzas_ordered
FROM customer_orders_new
GROUP BY dayname(order_time);

  
  B.RUNNER AND CUSTOMER EXPERIENCE
  
  1.How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
  select count(runner_id),week(registration_date,2021-01-01)
  from runners
  group by week(registration_date,2021-01-01);
  
  2.What was the average time in minutes it took for each runner to arrive 
  at the Pizza Runner HQ to pickup the order?
 select distinct(r.order_id),r.runner_id, c.order_time,r.pickup_time ,avg(timestampdiff(minute,c.order_time,r.pickup_time))
 from runner_orders_new r
 join customer_orders_new c
 on r.order_id = c.order_id
  where r.distance != 0
  group by r.runner_id;

  
  3.Is there any relationship between the number of pizzas and how long the order takes to prepare?
   select c.pizza_id ,avg(timestampdiff(minute,c.order_time,r.pickup_time))
 from runner_orders_new r
 join customer_orders_new c
 on r.order_id = c.order_id
  where r.cancellation not in ('Restaurant Cancellation','Customer Cancellation')
 group by c.pizza_id;
 
 4.What was the average distance travelled for each customer?
 
 with exact_orders as 
 (select * from runner_orders_new
  where cancellation not in ('Restaurant Cancellation','Customer Cancellation'))
  select c.customer_id, avg( e.distance) 
  from customer_orders_new c
  join exact_orders e
  on c.order_id=e.order_id
  group by c.customer_id;
  
  5.What was the difference between the longest and shortest delivery times for all orders?
  
   with exact_orders as 
 (select * from runner_orders_new
  where cancellation not in ('Restaurant Cancellation','Customer Cancellation'))
  select c.customer_id, max(e.distance),min(e.distance),(max(e.distance)-min(e.distance)) as difference
  from customer_orders_new c
  join exact_orders e
  on c.order_id=e.order_id;
  
  6.What was the average speed for each runner for each delivery
  and do you notice any trend for these values?
   with exact_orders as 
 (select * from runner_orders_new
  where cancellation not in ('Restaurant Cancellation','Customer Cancellation'))
 select order_id,runner_id,distance,duration, duration/60 as hours, distance/(duration/60 ) as speed
 from exact_orders;
  
  7.What is the successful delivery percentage for each runner?
  select runner_id, 
  round(100*sum(case when distance = 0 then 0
  else 1
  end) /count(*) )as points
  from runner_orders_new
  group by runner_id;
  
                           C.Ingredient Optimisation
1.What are the standard ingredients for each pizza?
select p.pizza_id,t.topping_name 
from pizza_recipes_new p
join  pizza_toppings t
on  p.topping_id=t.topping_id;


                                   D.PRICING AND RATINGS


1.If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
how much money has Pizza Runner made so far if there are no delivery fees?

select 
sum(case 
when pizza_id = 1 then 12
else 10
end )as price
from runner_orders_new r
join customer_orders_new c
on c.order_id=r.order_id
where r.distance != 0;



2.What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra

select c.pizza_id ,
(case 

when c.pizza_id = 1 and c.extras != 0 then 13
when c.pizza_id = 2 and c.extras != 0 then 11
when c.pizza_id = 1 then 12
when c.pizza_id = 2 then 10
end )as price
from runner_orders_new r
join customer_orders_new c
on c.order_id=r.order_id
where r.distance != 0;

3.The Pizza Runner team now wants to add an additional ratings system 
that allows customers to rate their runner,
how would you design an additional table for this new 
dataset - generate a schema for this new table and insert your own data 
for ratings for each successful customer order between 1 to 5.
drop table if exists ratings ;
create table ratings
( customer_id int,
runner_id int,
 ratings int,
 distance varchar(5));
 
 truncate ratings
 
 insert into dannys_dinner.ratings select c.customer_id,  r.runner_id,c.pizza_id,r.distance from 
 dannys_dinner.customer_orders_new c 
 join  dannys_dinner.runner_orders_new r  
 on c.order_id = r.order_id;
 


  
UPDATE ratings
SET ratings= (case
   when distance=0 then 0
   else FLOOR(1 + rand() * 5)
   end) x
   group by customer_id, runner_id



-- disable safe update mode
SET SQL_SAFE_UPDATES=0;
-- execute update statement
UPDATE table SET column='value';
-- enable safe update mode
SET SQL_SAFE_UPDATES=1;

  select * from ratings;

4.If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices
 with no cost for extras and each runner is paid $0.30 per kilometre traveled -
 how much money does Pizza Runner have left over after these deliveries?
 
with sum1 as( select
sum(case 
when pizza_id = 1 then 12
else 10
end )as price ,sum(r.distance*0.3) as paid
from runner_orders_new r
join customer_orders_new c
on c.order_id=r.order_id
where r.distance != 0)

select price-paid from sum1;


