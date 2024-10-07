
SELECT * FROM users;








--1)  Total amount each customer spent on Skipthe Dishes

SELECT userid,SUM(price) AS total_amount 
FROM sales
JOIN
product
ON 
sales.product_id = product.product_id
GROUP BY 
sales.userid;

--2)  How many days each customer visited Skip TheDishes

SELECT COUNT(DISTINCT created_date) AS Visited_days
FROM sales
GROUP BY userid;

--SELECT COUNT(*) AS Visited_days
--FROM sales
--GROUP BY userid;
-- ctrl+k ctrl+c 
-- ctrl+k ctrl+U


--3) First product purchased by each of the customer


WITH cust_pur(userid,purchase_number,product_name) AS 
(
SELECT sales.userid ,ROW_NUMBER() OVER (PARTITION BY userid ORDER BY created_date ASC) AS purchase_number, product_name 
FROM sales
JOIN
product 
ON
sales.product_id = product.product_id
)
SELECT userid,purchase_number,product_name
FROM cust_pur
WHERE purchase_number=1;


-- We have used CTE instead of Subquery in From Clause 


--SELECT userid , product_name 
--FROM sales
--JOIN
--product 
--ON
--sales.product_id = product.product_id 
--GROUP by userid
--HAVING COUNT(created_date)=1
--ORDER BY userid ASC, created_date ASC;
-- also observe , how powerful are windows function in terms of showing those columns which are not part of group by function

-- product id 1 is the product that basically is the product bought by every customer intitally 


--4)  Most pruchased item and how many time it is purchased by each customer 


-- Most Purchase item 
--SELECT TOP(1) sales.product_id,COUNT(*) AS quantity
--FROM 
--sales 
--JOIN
--product
--ON sales.product_id=product.product_id
--GROUP BY sales.product_id
--ORDER BY quantity DESC

SELECT TOP(1) product_id
FROM 
sales 
GROUP BY product_id
ORDER BY COUNT(product_id) DESC;

-- Observer here as we want only one Field in select list so we move count in orderby only 

-- How many time each customer pruchase it


--WITH most_purchased(pid,qunatity) AS 
--(
--SELECT TOP(1) sales.product_id,COUNT(*) AS quantity
--FROM 
--sales 
--JOIN
--product
--ON sales.product_id=product.product_id
--GROUP BY sales.product_id
--ORDER BY quantity DESC
--)
--SELECT userid,COUNT(*) as purchased_times
--FROM sales
--WHERE product_id= 
--(
--SELECT pid 
--FROM most_purchased
--)
--GROUP BY userid;





-- OTHER OPTION
SELECT userid,COUNT(*) as purchased_times
FROM sales
WHERE product_id=
(SELECT TOP(1) product_id
FROM 
sales 
GROUP BY product_id
ORDER BY COUNT(product_id) DESC)
GROUP BY userid;

-- INFERENCE product id 2 is the one which is bought most of the times  


--5) WHICH ITEM is popular for each of the customer  


WITH popular_product(userid,product_id,quantity) AS
(
SELECT  userid,product_id,count(product_id) as quantity
FROM sales
GROUP BY userid,product_id
),
popular_prodcut_name(userid,product_id,quantity,ranking) AS 
(
SELECT userid,product_id,quantity,DENSE_RANK() OVER(PARTITION BY userid ORDER BY quantity DESC) AS ranking
FROM popular_product
)
SELECT userid,product_id
FROM popular_prodcut_name 
WHERE ranking=1



-- in argmax kind of sitation using window function is very easy hack
-- observer here we use multiple common table expression


--- USING RANK WILL SOLVE THE PROBLEM 


-- 6) what product is purchased by customer after they become member

-- Is their a certain product which is attracting customers to become GOLD member

SELECT gold_userid,salespid
FROM
(
SELECT 
sales.userid as sales_userid,
goldusers_signup.userid as gold_userid,
sales.product_id as salespid,
gold_signup_date,created_date,
RANK() OVER (PARTITION BY sales.userid ORDER BY created_date) AS ranking 
FROM goldusers_signup
JOIN
sales
ON sales.userid=goldusers_signup.userid and created_date >= gold_signup_date
) AS rankedsales
WHERE 
ranking = 1

-- most of times I use CTE for readablity 

-- Alwyas take care of Aliases 

--7) Which ITEM was purchased just beofre becomeing a gold member 

SELECT gold_userid,salespid
FROM
(
SELECT 
sales.userid as sales_userid,
goldusers_signup.userid as gold_userid,
sales.product_id as salespid,
gold_signup_date,created_date,
RANK() OVER (PARTITION BY sales.userid ORDER BY created_date DESC) AS ranking 
FROM goldusers_signup
JOIN
sales
ON sales.userid=goldusers_signup.userid and created_date <= gold_signup_date
) AS rankedsales
WHERE 
ranking = 1



-- 8) What is total order and amount spent before they are becoming gold member 

-- 
SELECT DISTINCT goldusers_signup.userid, COUNT(*) OVER (PARTITION BY sales.userid) AS total_orders,SUM(price) OVER (PARTITION BY sales.userid) AS total_amount
FROM 
goldusers_signup
JOIN
sales
ON goldusers_signup.userid=sales.userid and created_date <= gold_signup_date
JOIN 
product
ON sales.product_id=product.product_id

--OR this query can also be run with just group by 


--9)
-- If buying a Prodcut generates points 
-- product ID 1 genrates 1 points for every 5 dollars
-- product ID 2 genrates 5 point for every 10 dollars
-- product ID 3 genrates 1 points for every 5 dollars

--Calcualte Points for each customer  

SELECT userid, SUM(points) AS total_points
FROM
(
SELECT userid,sales.product_id,
CASE
WHEN sales.product_id=1 THEN price/5
WHEN sales.product_id=2 THEN price/2
WHEN sales.product_id=3 THEN price/5
ELSE 0
END AS points
FROM sales
JOIN
product
ON sales.product_id=product.product_id
) AS t1
GROUP BY userid

--AND Tell which product has got highest point till now 

SELECT TOP(1) product_id , SUM(points) as Total_sum
FROM
(
SELECT userid,sales.product_id AS product_id,
CASE
WHEN sales.product_id=1 THEN price/5
WHEN sales.product_id=2 THEN price/2
WHEN sales.product_id=3 THEN price/5
ELSE 0
END AS points
FROM sales
JOIN
product
ON sales.product_id=product.product_id
) AS t1
GROUP BY product_id
ORDER BY Total_sum DESC









SELECT * 
FROM 
users;

SELECT * 
FROM 
goldusers_signup;


SELECT * 
FROM 
product;

SELECT * 
FROM 
sales;