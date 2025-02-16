USE magist;
SELECT 
    (SELECT COUNT(DISTINCT seller_id) FROM sellers) AS total_sellers,
    (SELECT COUNT(DISTINCT seller_id) FROM order_items oi
        LEFT JOIN products p USING (product_id) 
        LEFT JOIN product_category_name_translation pt USING (product_category_name)
        WHERE pt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
    ) AS tech_sellers,
    
    (SELECT ROUND(SUM(payment_value), 2) FROM order_payments) AS total_revenue,
    
    (SELECT ROUND(SUM(op.payment_value), 2) FROM order_items o
        LEFT JOIN products p USING (product_id) 
        LEFT JOIN product_category_name_translation pt USING (product_category_name)
        LEFT JOIN order_payments op ON o.order_id = op.order_id
        WHERE pt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony")
    ) AS tech_revenue;



###  Average Order Value (AOV) for Tech vs. General Sellers. tech sellers make higher-value sales per order?
SELECT 
    'All Sellers' AS seller_type, 
    ROUND(SUM(op.payment_value) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM order_items oi
LEFT JOIN order_payments op USING (order_id)
UNION
SELECT 
    'Tech Sellers' AS seller_type, 
    ROUND(SUM(op.payment_value) / COUNT(DISTINCT oi.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN order_payments op ON oi.order_id = op.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pcnt 
    ON p.product_category_name = pcnt.product_category_name
WHERE pcnt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony");


##Number of Orders Per Seller (All vs. Tech)
##Are tech sellers getting fewer orders than general sellers?
SELECT 
    'All Sellers' AS seller_type, 
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT seller_id), 2) AS avg_orders_per_seller
FROM order_items
UNION
SELECT 
    'Tech Sellers' AS seller_type, 
    ROUND(COUNT(DISTINCT order_id) / COUNT(DISTINCT seller_id), 2) AS avg_orders_per_tech_seller
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pcnt 
    ON p.product_category_name = pcnt.product_category_name
WHERE pcnt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony");


##Are Tech Products Priced Higher or Lower Than General Products?
##If tech products have lower prices, it could explain why tech sellers earn less overall.
SELECT 
    'All Products' AS product_type, 
    ROUND(AVG(o.price), 2) AS avg_product_price
FROM order_items o
UNION
SELECT 
    'Tech Products' AS product_type, 
    ROUND(AVG(o.price), 2) AS avg_tech_product_price
FROM order_items o
JOIN products p USING(product_id)
JOIN product_category_name_translation pcnt 
    ON p.product_category_name = pcnt.product_category_name
WHERE pcnt.product_category_name_english IN ("audio", "electronics", "computers_accessories", "pc_gamer", "computers", "tablets_printing_image", "telephony");

### Delivered order percentage by states
SELECT 
    g.state, 
    COUNT(DISTINCT oi.order_id) AS total_delivered_orders,
    ROUND(COUNT(DISTINCT oi.order_id) * 100.0 / 
          (SELECT COUNT(DISTINCT order_id) 
           FROM orders 
           WHERE order_status = 'delivered'), 2) AS state_order_percentage
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN geo g ON s.seller_zip_code_prefix = g.zip_code_prefix
WHERE o.order_status = 'delivered'
GROUP BY g.state
ORDER BY total_delivered_orders DESC;

SELECT 
    g.state, 
    COUNT(DISTINCT oi.order_id) AS tech_delivered_orders,
    ROUND(
        COUNT(DISTINCT oi.order_id) * 100.0 / 
        (SELECT COUNT(DISTINCT oi.order_id) 
         FROM order_items oi
         JOIN orders o ON oi.order_id = o.order_id
         JOIN products p ON oi.product_id = p.product_id
         JOIN product_category_name_translation pt 
             ON p.product_category_name = pt.product_category_name
         WHERE o.order_status = 'delivered'
         AND pt.product_category_name_english IN ('audio', 'electronics', 'computers_accessories', 
                                                  'pc_gamer', 'computers', 'tablets_printing_image', 
                                                  'telephony')
        ), 2
    ) AS tech_order_percentage
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
JOIN geo g ON s.seller_zip_code_prefix = g.zip_code_prefix
JOIN products p ON oi.product_id = p.product_id
JOIN product_category_name_translation pt ON p.product_category_name = pt.product_category_name
WHERE o.order_status = 'delivered'
AND pt.product_category_name_english IN ('audio', 'electronics', 'computers_accessories', 
                                          'pc_gamer', 'computers', 'tablets_printing_image', 
                                          'telephony')
GROUP BY g.state
ORDER BY tech_delivered_orders DESC;




