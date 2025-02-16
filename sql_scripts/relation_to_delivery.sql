USE magist;
# In relation to the delivery time:

#1. What’s the average time between the order being placed and the product being delivered? (12.5 Days) 
SELECT AVG(datediff(order_purchase_timestamp, order_delivered_customer_date)) FROM orders;

#1a. average time between estimated and delivered date (11.9 Days) 
SELECT AVG(datediff(order_delivered_customer_date, order_estimated_delivery_date)) FROM orders;

#1b. difference in delivered vs estimated by tech relevant categories
SELECT product_category_name_english, AVG(datediff(order_delivered_customer_date, order_estimated_delivery_date))
FROM orders
INNER JOIN order_items
ON orders.order_id=order_items.order_id
INNER JOIN products 
ON products.product_id=order_items.product_id
INNER JOIN product_category_name_translation 
ON product_category_name_translation.product_category_name=products.product_category_name 
WHERE product_category_name_english in ('telephony', 'computers_accessories', 'electronics', 'computers', 'audio')
GROUP BY product_category_name_english;

#2. How many orders are delivered on time vs orders delivered with a delay? Total = 96476 orders delivered 
SELECT COUNT(datediff(order_delivered_customer_date, order_estimated_delivery_date))
FROM orders; 

#2. How many orders are delivered on time vs orders delivered with a delay? 90750 Orders delivered =1 or less days after estimation (94%) and 5726 delivered over 1 days after estimation (5.9%)
#PERCENTAGES ARE NOT PULLING CORRECT  
SELECT COUNT(datediff(order_delivered_customer_date, order_estimated_delivery_date)), 
(COUNT(datediff(order_delivered_customer_date, order_estimated_delivery_date)) / (SELECT COUNT(*)  FROM orders)*100) AS Percentage
FROM orders 
WHERE datediff(order_delivered_customer_date, order_estimated_delivery_date) >1;

#3. Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT product_category_name_english, AVG(datediff(order_delivered_customer_date, order_estimated_delivery_date)) AS average_diff_est_delivered
FROM orders
INNER JOIN order_items
ON orders.order_id=order_items.order_id
INNER JOIN products 
ON products.product_id=order_items.product_id
INNER JOIN product_category_name_translation 
ON product_category_name_translation.product_category_name=products.product_category_name 
GROUP BY product_category_name_english
ORDER BY average_diff_est_delivered ASC;

#Playing around with the weigth to see if there is a pattern for large products 
SELECT count(o.order_id) AS number_of_orders,
CASE
    WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
    ELSE 'delayed'
    END AS delivery_date_check,
CASE
    WHEN product_weight_g > 19999 THEN 'VERY HEAVY 20kg+'
    WHEN product_weight_g BETWEEN 10000 AND 19999 THEN 'HEAVY 10kg+'
    WHEN product_weight_g BETWEEN 5000 AND 9999 THEN 'MEDIUM 5kg+'
    ELSE 'LIGHT <5kg'
    END AS weight_categories
FROM
    orders o
RIGHT JOIN
    order_items oi
ON
    o.order_id=oi.order_id
RIGHT JOIN
    products p
ON
    oi.product_id=p.product_id
GROUP BY
    delivery_date_check, weight_categories
ORDER BY
    weight_categories DESC;

SELECT delivery_status, COUNT(*)
FROM 
(SELECT TIMESTAMPDIFF (DAY, order_estimated_delivery_date,order_delivered_customer_date),
CASE 
WHEN (TIMESTAMPDIFF (DAY, order_estimated_delivery_date,order_delivered_customer_date)) > 0 THEN "delivered with a delay"
WHEN (TIMESTAMPDIFF (DAY, order_estimated_delivery_date,order_delivered_customer_date)) = 0 THEN "delivered on time"
ELSE "delivered earlier"
END delivery_status
FROM orders) AS delivery_table
GROUP BY delivery_status;

#Average freight value by tech category
SELECT product_category_name_english, 
AVG(freight_value) AS average
FROM product_category_name_translation 
INNER JOIN products 
ON product_category_name_translation.product_category_name=products.product_category_name 
INNER JOIN order_items 
ON products.product_id=order_items.product_id
WHERE product_category_name_english in ('telephony', 'computers_accessories', 'electronics', 'computers', 'audio')
GROUP BY product_category_name_english;

SELECT count(o.order_id) AS number_of_orders,
CASE
    WHEN timestampdiff(day, order_estimated_delivery_date, order_delivered_customer_date) < 1 then 'ON_time'
    ELSE 'delayed'
    END AS delivery_date_check,
CASE
    WHEN product_weight_g > 19999 THEN 'VERY HEAVY 20kg+'
    WHEN product_weight_g BETWEEN 10000 AND 19999 THEN 'HEAVY 10kg+'
    WHEN product_weight_g BETWEEN 5000 AND 9999 THEN 'MEDIUM 5kg+'
    ELSE 'LIGHT <5kg'
    END AS weight_categories
FROM
    orders o
RIGHT JOIN
    order_items oi
ON
    o.order_id=oi.order_id
RIGHT JOIN
    products p
ON
    oi.product_id=p.product_id
GROUP BY
    delivery_date_check, weight_categories
ORDER BY
    weight_categories DESC;

SELECT SUM(price) FROM order_items;

SELECT SUM(payment_value) FROM order_payments;

SELECT SUM(price + freight_value) FROM order_items;

SELECT SUM(order_item_id) FROM order_items;

SELECT state, 
COUNT(order_item_id) AS count_orders, 
(COUNT(order_item_id) / (SELECT COUNT(*)  FROM order_items)*100) AS Percentage
FROM geo
INNER JOIN sellers
ON geo.zip_code_prefix=sellers.seller_zip_code_prefix
INNER JOIN order_items 
ON sellers.seller_id=order_items.seller_id
GROUP BY state;

SELECT state, 
COUNT(order_item_id) AS count_orders
FROM geo
INNER JOIN sellers
ON geo.zip_code_prefix=sellers.seller_zip_code_prefix
INNER JOIN order_items 
ON sellers.seller_id=order_items.seller_id;