
SELECT  
    order_status,

    ROUND(
        julianday(order_estimated_delivery_date) -
        julianday(order_purchase_timestamp),
        2
    ) AS selisih_hari,

    ROUND(
        AVG(
            julianday(order_estimated_delivery_date) -
            julianday(order_purchase_timestamp)
        ) OVER (),
        2
    ) AS rata_rata,

    CASE
        WHEN (
            julianday(order_estimated_delivery_date) -
            julianday(order_purchase_timestamp)
        ) <= AVG(
            julianday(order_estimated_delivery_date) -
            julianday(order_purchase_timestamp)
        ) OVER ()
        THEN 'tepat_waktu'
        ELSE 'terlalu_lama'
    END AS status_delivery

FROM orders
WHERE order_status = 'delivered'
LIMIT 10;

SELECT 
    order_status,
    COUNT(*) AS menghitung_status
FROM orders
GROUP BY order_status;

SELECT
    order_id,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,

    CASE
        WHEN order_purchase_timestamp > order_approved_at
            THEN 'purchase_after_approval'

        WHEN order_approved_at > order_delivered_carrier_date
            THEN 'approval_after_carrier'

        WHEN order_delivered_carrier_date > order_delivered_customer_date
            THEN 'carrier_after_customer'
        
        WHEN order_estimated_delivery_date < order_delivered_customer_date
            THEN 'terlambat'

        ELSE 'not_an_anomalies'
    END AS date_status,

    COUNT (*)
FROM orders
GROUP BY date_status;

WITH delivery_check AS (
    SELECT
        order_id,
        order_purchase_timestamp,
        order_delivered_customer_date,
        order_estimated_delivery_date,

        CASE
            WHEN date(order_delivered_customer_date)
                 > date(order_estimated_delivery_date)
            THEN 1
            ELSE 0
        END AS terlambat

    FROM orders
    WHERE
        order_purchase_timestamp >= '2018-01-01'
        AND order_purchase_timestamp < '2018-07-01'
        AND order_status = 'delivered'
        AND date(order_delivered_customer_date) IS NOT NULL
        AND date(order_estimated_delivery_date) IS NOT NULL
)

SELECT
    COUNT(*) AS eligible_orders,
    SUM(terlambat) AS late_orders,
    ROUND(
        SUM(terlambat) * 100.0 / COUNT(*),
        2
    ) AS late_percentage
FROM delivery_check;

SELECT
    order_id,
    date(order_delivered_customer_date) AS actual,
    date(order_estimated_delivery_date) AS estimated,

    julianday(date(order_delivered_customer_date))
    - julianday(date(order_estimated_delivery_date)) AS late_days

FROM orders
WHERE
    order_purchase_timestamp >= '2018-01-01'
    AND order_purchase_timestamp < '2018-07-01'
    AND order_status = 'delivered'
    AND date(order_delivered_customer_date)
        > date(order_estimated_delivery_date);


WITH late_orders AS (
    SELECT
        order_id,
        julianday(date(order_delivered_customer_date))
        - julianday(date(order_estimated_delivery_date)) AS late_days

    FROM orders
    WHERE
        order_purchase_timestamp >= '2018-01-01'
        AND order_purchase_timestamp < '2018-07-01'
        AND order_status = 'delivered'
        AND date(order_delivered_customer_date)
            > date(order_estimated_delivery_date)
)

SELECT
    CASE
        WHEN late_days BETWEEN 1 AND 3 THEN '1-3 hari'
        WHEN late_days BETWEEN 4 AND 7 THEN '4-7 hari'
        ELSE '>7 hari'
    END AS severity,

    COUNT(*) AS jumlah_order

FROM late_orders
GROUP BY severity;

WITH eligible_orders AS (
    SELECT
        order_id,
        customer_id,

        julianday(date(order_delivered_customer_date))
        - julianday(date(order_estimated_delivery_date))
        AS late_days

    FROM orders
    WHERE
        order_purchase_timestamp >= '2018-01-01'
        AND order_purchase_timestamp < '2018-07-01'
        AND order_status = 'delivered'
        AND date(order_delivered_customer_date) IS NOT NULL
        AND date(order_estimated_delivery_date) IS NOT NULL
)

SELECT
    COALESCE(c.customer_state, 'UNKNOWN') AS state,

    COUNT(*) AS eligible_orders,

    SUM(
        CASE
            WHEN e.late_days > 0 THEN 1
            ELSE 0
        END
    ) AS late_orders,

    ROUND(
        SUM(CASE WHEN e.late_days > 0 THEN 1 ELSE 0 END)
        * 100.0 / COUNT(*),
        2
    ) AS late_percentage,

    ROUND(
        AVG(
            CASE
                WHEN e.late_days > 0 THEN e.late_days
                ELSE NULL
            END
        ),
        2
    ) AS avg_late_days

FROM eligible_orders AS e
LEFT JOIN customers AS c
    ON e.customer_id = c.customer_id

GROUP BY COALESCE(c.customer_state, 'UNKNOWN')
ORDER BY late_orders DESC;

WITH delivery_analysis AS (
    SELECT
        o.order_id,

        CASE
            WHEN date(o.order_delivered_customer_date)
                 > date(o.order_estimated_delivery_date)
            THEN 'terlambat'
            ELSE 'tepat_waktu'
        END AS status_delivery,

        julianday(o.order_approved_at)
        - julianday(o.order_purchase_timestamp)
        AS purchase_to_approval,

        julianday(o.order_delivered_carrier_date)
        - julianday(o.order_approved_at)
        AS approval_to_carrier,

        julianday(o.order_delivered_customer_date)
        - julianday(o.order_delivered_carrier_date)
        AS carrier_to_customer

    FROM orders AS o
    JOIN customers AS c
        ON o.customer_id = c.customer_id

    WHERE
        o.order_purchase_timestamp >= '2018-01-01'
        AND o.order_purchase_timestamp < '2018-07-01'
        AND o.order_status = 'delivered'
        --AND c.customer_state = 'SP'

        AND julianday(o.order_purchase_timestamp) IS NOT NULL
        AND julianday(o.order_approved_at) IS NOT NULL
        AND julianday(o.order_delivered_carrier_date) IS NOT NULL
        AND julianday(o.order_delivered_customer_date) IS NOT NULL
        AND date(o.order_estimated_delivery_date) IS NOT NULL

        AND o.order_purchase_timestamp <= o.order_approved_at
        AND o.order_approved_at <= o.order_delivered_carrier_date
        AND o.order_delivered_carrier_date <= o.order_delivered_customer_date
)

SELECT
    status_delivery,
    COUNT(*) AS jumlah_order,

    ROUND(AVG(purchase_to_approval), 2) AS avg_purchase_approval,
    ROUND(AVG(approval_to_carrier), 2) AS avg_approval_carrier,
    ROUND(AVG(carrier_to_customer), 2) AS avg_carrier_customer

FROM delivery_analysis
GROUP BY status_delivery;

SELECT *
FROM order_reviews
LIMIT 10;

WITH reviews_delivery AS (
    SELECT
        o.order_id,
        julianday(date(o.order_delivered_customer_date))
        - julianday(date(o.order_estimated_delivery_date)) AS late_days,
        r.review_score AS review_score

    FROM orders AS o
    LEFT JOIN order_reviews AS r
        ON o.order_id = r.order_id
    WHERE
        order_purchase_timestamp >= '2018-01-01'
        AND order_purchase_timestamp < '2018-07-01'
        AND order_status = 'delivered'
        AND date(order_delivered_customer_date)
            > date(order_estimated_delivery_date)
)

SELECT
    CASE
        WHEN late_days BETWEEN 1 AND 3 THEN '1-3 hari'
        WHEN late_days BETWEEN 4 AND 7 THEN '4-7 hari'
        ELSE '>7 hari'
    END AS severity,

    COUNT(*) AS jumlah_order,
    AVG(review_score) AS rata_rata_score

FROM reviews_delivery 
GROUP BY severity;