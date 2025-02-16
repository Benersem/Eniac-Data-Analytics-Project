USE `magist`;
# 1. How many orders are in the dataset:
SELECT COUNT(*) 
AS orders_count
FROM orders;

#2. Are orders actually delivered?
SELECT order_status, COUNT(*) 
AS orders 
FROM orders 
GROUP BY order_status;

#3. Is Magist having user growth?
###### There is  a drastic drop in orders in  September 2018, gradually growth in 2017 
SELECT COUNT(order_id) , YEAR(order_purchase_timestamp) AS year_order, MONTH(order_purchase_timestamp) AS month_order 
FROM orders
GROUP BY year_order, month_order
ORDER BY year_order DESC, month_order DESC;

#4. How many products are there on the products table? 
SELECT COUNT(DISTINCT product_id) AS unique_product_count
FROM products ;

#5. Which are the categories with the most products
SELECT product_category_name_english, COUNT(DISTINCT product_id) AS count_product
FROM products 
LEFT JOIN product_category_name_translation 
ON product_category_name_translation.product_category_name = products.product_category_name 
GROUP BY product_category_name_english
ORDER BY count_product DESC;

#6. How many of those products were present in actual transactions?
SELECT count(DISTINCT product_id) AS n_products
FROM order_items;

#### 6a. Percentage of tech products
SELECT pt.product_category_name_english, COUNT(order_id) AS Order_quantity , (COUNT(order_id) / (SELECT COUNT(*)  FROM order_items)*100) AS Percentage
FROM products p
RIGHT JOIN order_items o
ON p.product_id = o.product_id
JOIN product_category_name_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english in ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY pt.product_category_name_english
ORDER BY COUNT(order_id) DESC; 

#7. What’s the price for the most expensive and cheapest products? 
SELECT MAX(price) AS most_expensive, MIN(price) AS cheapest
FROM order_items;

##### 7a. max , min, avg prices of products for each category
SELECT pt.product_category_name_english AS category, MAX(price) AS highest, MIN(price) AS lowest, AVG(price) AS average
FROM product_category_name_translation pt
INNER JOIN products p
ON pt.product_category_name = p.product_category_name 
INNER JOIN order_items o
ON p.product_id = o.product_id 
WHERE pt.product_category_name_english in ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY category; 
 
 #8. What are the highest and lowest payment values?
SELECT MAX(payment_value) AS most_expensive, MIN(payment_value)
FROM order_payments ;

################################################  BUSINESS QUESTIONS ###########################
##### 3.1 IN RELATION TO THE PRODUCTS

##### 1.What categories of tech products does Magist have?

SELECT product_category_name_english AS category, COUNT(product_id) 
FROM products p
LEFT JOIN product_category_name_translation pt 
ON pt.product_category_name = p.product_category_name 
GROUP BY category 
ORDER BY category ASC ;
###### telephony', 'computers_accessories', 'electronics', 'computers', 'audio'

#######2. How many products of these tech categories have been sold (within the time window of the database snapshot)? 
####### What percentage does that represent from the overall number of products sold?
SELECT pt.product_category_name_english AS category, 
		COUNT(order_id) AS order_quantity , 
        ROUND((COUNT(order_id) / (SELECT COUNT(*)  FROM order_items) * 100), 2) AS percentage_sold
FROM products p
RIGHT JOIN order_items o
ON p.product_id = o.product_id
JOIN product_category_name_translation pt
ON p.product_category_name = pt.product_category_name
WHERE product_category_name_english in ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY category
ORDER BY order_quantity DESC; 



####### 3. What’s the average price of the products being sold?

SELECT pt.product_category_name_english AS category, MAX(price) AS highest, MIN(price) AS lowest, ROUND(AVG(price), 2) AS average
FROM product_category_name_translation pt
INNER JOIN products p
ON pt.product_category_name = p.product_category_name 
INNER JOIN order_items o
ON p.product_id = o.product_id 
WHERE pt.product_category_name_english in ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY category
ORDER BY highest DESC;

###### What percentage of all orderes are delivered?
SELECT 
    ((SUM(order_status = 'delivered') / COUNT(*)) * 100) AS delivered_percentage
FROM orders;


##### 4. Are expensive tech products popular? 
SELECT product_category_name_english AS category, 
		ROUND(AVG(price), 2) AS average_price, 
		COUNT(order_id) AS order_quantity,
        ROUND((COUNT(o.order_id) * 100.0) / (SELECT COUNT(*) FROM order_items), 2) AS percentage_sold
FROM product_category_name_translation pt
LEFT JOIN products p
ON pt.product_category_name = p.product_category_name 
INNER JOIN order_items o
ON p.product_id = o.product_id 
WHERE product_category_name_english in ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY product_category_name_english
ORDER BY order_quantity DESC;

SELECT COUNT(o.product_id),
CASE
WHEN price > 1000 THEN 'expensive'
WHEN price > 100 THEN 'mid range'
ELSE 'cheap'
END AS 'price_range'
FROM order_items AS o
LEFT JOIN products p ON p.product_id=o.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name=t.product_category_name
WHERE t.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
GROUP BY price_range;

################################################### FROM HANNE'S SESSION ##################################
SELECT order_id, datediff(order_delivered_carrier_date,order_purchase_timestamp) as delivery
FROM orders
WHERE order_status = "delivered"
ORDER BY delivery ASC;

SELECT AVG(payment_value)
FROM order_payments ;

SET @average_payment = (SELECT AVG(payment_value) FROM order_payments) ;
##################################################################################################

###### 3.2 IN RELATION TO THE SELLER

##### How many months of data are included in the magist database?
SELECT COUNT(DISTINCT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)) AS n_months_data 
FROM orders;
# There are 25 months of data

#### How many sellers are there? 
SELECT COUNT(seller_id)
FROM sellers ;
## There are 3095 sellers.

### How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
SELECT COUNT(DISTINCT seller_id) AS n_tech_seller, 
       ROUND(COUNT(DISTINCT o.seller_id) * 100.0 / (SELECT COUNT(DISTINCT seller_id) FROM order_items), 2) AS tech_seller_percentage
FROM order_items o 
LEFT JOIN products p USING (product_id) 
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
ORDER BY n_tech_seller DESC;

## There are 454 tech seller. which is 14.67 % of all sellers. This number depends on the categories we choose


#### What is the total amount earned by all sellers? 
SELECT 
    SUM(oi.price) AS total
FROM order_items oi
LEFT JOIN orders o USING (order_id)
WHERE o.order_status NOT IN ('unavailable' , 'canceled');
##Total earnings from all sellers = 13494400.74

#### What is the total amount earned by all Tech sellers?
SELECT SUM(oi.price) AS total
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled') 
AND pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories', 'pc_gamer','computers', 'tablets_printing_image', 'telephony');
### Total earnings from tech sellers = 1666211.28


#### Can you work out the average monthly income of all sellers?
SELECT ROUND(SUM(oi.price), 2) AS total, 
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)), 2) AS earnings_per_seller,
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)/(25)), 2) AS monthly_earnings_per_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled');
### earning per seller = 4420.05	monthly earning per seller =176.8


##### Can you work out the average monthly income of Tech sellers?
SELECT ROUND(SUM(oi.price), 2) AS total, 
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)), 2) AS earnings_per_seller,
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)/(25)), 2) AS monthly_earnings_per_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled') 
AND pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories', 'pc_gamer','computers', 'tablets_printing_image', 'telephony');
## earning per tech seller = 3727.54	monthly earning per tech seller =149.1
