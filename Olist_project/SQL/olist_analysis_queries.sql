-- =====================================================
-- Olist E-Commerce Analysis (PostgreSQL)
-- =====================================================


-- Q1. Business overview: orders, revenue, average order value
SELECT
    COUNT(DISTINCT o.order_id)                               AS total_orders,
    ROUND(SUM(oi.price), 2)                                  AS total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2)     AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';


-- Q2. Top 10 product categories by revenue
SELECT
    COALESCE(t.product_category_name_english, p.product_category_name, 'unknown') AS category,
    COUNT(DISTINCT oi.order_id)  AS orders,
    ROUND(SUM(oi.price), 2)      AS revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY revenue DESC
LIMIT 10;


-- Q3. Revenue by customer state
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)  AS orders,
    ROUND(SUM(oi.price), 2)     AS revenue
FROM orders o
JOIN customers c    ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;


-- Q4. Monthly sales trend
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)::date  AS month,
    COUNT(DISTINCT o.order_id)                             AS orders,
    ROUND(SUM(oi.price), 2)                                AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY 1
ORDER BY 1;


-- Q5. Late deliveries and delivery time by state
SELECT
    c.customer_state,
    COUNT(*) AS delivered_orders,
    SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
             THEN 1 ELSE 0 END) / COUNT(*), 1) AS late_pct,
    ROUND(AVG(EXTRACT(EPOCH FROM (o.order_delivered_customer_date - o.order_purchase_timestamp)) / 86400)::numeric, 1)
        AS avg_delivery_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY late_pct DESC;
