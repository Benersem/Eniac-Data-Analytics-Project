use magist;

-- Question 1. Categories of tech goods Magist sells --
select distinct product_category_name_english 
from product_category_name_translation 
left join products on product_category_name_translation.product_category_name =  products.product_category_name;
-- here the % of the relatable categories to the whole product range should be counted 
-- relatable product categories are: audio, electronics, computers_accessoires, computers 

-- Question 2. Amount of products sold in each category 

-- The number of sold products in tech categories
select count(pr.product_id)
from order_items as oi
right join products as pr on oi.product_id = pr.product_id
right join product_category_name_translation as translation on pr.product_category_name = translation.product_category_name
where translation.product_category_name_english in ('electronics', 'computers', 'computers_accessories');

-- The number of all sold products
select count(pr.product_id)
from order_items as oi
right join products as pr on oi.product_id = pr.product_id
right join product_category_name_translation as translation on pr.product_category_name = translation.product_category_name;
-- Here the percentage of the sold tech products should be counted

-- Question 3. The average price of the sold products
select avg(price)
from order_items as oi
right join products as pr on oi.product_id = pr.product_id
right join product_category_name_translation as translation on pr.product_category_name = translation.product_category_name
where translation.product_category_name_english in ('electronics', 'computers', 'computers_accessories');

-- Question 4. Are expensive tech products popular?

-- Number of items sold in tech category (price is higher than the average price in the Question 3)
select count(oi.product_id) 
from order_items as oi
right join products as pr on oi.product_id = pr.product_id
right join product_category_name_translation as translation on pr.product_category_name = translation.product_category_name
where translation.product_category_name_english in ('electronics', 'computers', 'computers_accessories') and price > 120
order by price asc;

-- Overall number of items sold via Magist
select count(oi.product_id)
from order_items as oi
right join products as pr on oi.product_id = pr.product_id
right join product_category_name_translation as translation on pr.product_category_name = translation.product_category_name;









