-- Olist: one clean view for Power BI (PostgreSQL)
-- Joins all 5 tables and adds delivery status + delivery days.

CREATE VIEW order_details AS
SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp::date        AS purchase_date,
    o.order_delivered_customer_date::date   AS delivered_date,
    o.order_estimated_delivery_date::date   AS estimated_date,
    c.customer_unique_id,
    c.customer_city,
    c.customer_state,
    oi.order_item_id,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    CASE
        WHEN o.order_delivered_customer_date IS NULL THEN NULL
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND((EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::numeric, 1)
        AS delivery_days
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p     ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name;


