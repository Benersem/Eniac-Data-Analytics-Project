###### 3.2 IN RELATION TO THE SELLER

USE magist;
##### How many months of data are included in the magist database?
SELECT COUNT(DISTINCT YEAR(order_purchase_timestamp), MONTH(order_purchase_timestamp)) AS n_months_data 
FROM orders;
# There are 25 months of data

#### How many sellers are there? 
SELECT COUNT(seller_id) AS n_seller
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
    SUM(oi.price) AS total_earnings_all_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
WHERE o.order_status NOT IN ('unavailable' , 'canceled');
##Total earnings from all sellers = 13494400.74

#### What is the total amount earned by all Tech sellers?
SELECT SUM(oi.price) AS total_earnings_tech_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled') 
AND pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories', 'pc_gamer','computers', 'tablets_printing_image', 'telephony');
### Total earnings from tech sellers = 1666211.28


#### Can you work out the average monthly income of all sellers?
SELECT ROUND(SUM(oi.price), 2) AS total_earnings_all_seller, 
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)), 2) AS earnings_per_seller,
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)/(25)), 2) AS monthly_earnings_per_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled');
### earning per seller = 4420.05	monthly earning per seller =176.8


##### Can you work out the average monthly income of Tech sellers?
SELECT ROUND(SUM(oi.price), 2) AS total_earnings_tech_seller, 
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)), 2) AS earnings_per_tech__seller,
       ROUND((SUM(oi.price) / COUNT(DISTINCT seller_id)/(25)), 2) AS monthly_earnings_per_tech_seller
FROM order_items oi
LEFT JOIN orders o USING (order_id)
LEFT JOIN products p USING (product_id)
LEFT JOIN product_category_name_translation pt USING (product_category_name)
WHERE o.order_status NOT IN ('unavailable' , 'canceled') 
AND pt.product_category_name_english IN ('audio' , 'electronics', 'computers_accessories', 'pc_gamer','computers', 'tablets_printing_image', 'telephony');
## earning per tech seller = 3727.54	monthly earning per tech seller =149.1