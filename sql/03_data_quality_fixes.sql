-- ============================================================
-- Logistics Operations Performance Dashboard
-- Data Quality Checks & Synthetic Data Refinements
-- PostgreSQL
-- ============================================================
-- Purpose:
-- Validate the generated logistics dataset and correct patterns
-- that appeared unrealistic during exploratory analysis.
--
-- Examples addressed:
--   • Referential integrity
--   • Route SLA distribution
--   • Delivery attempt behaviour
--   • Issue-type distribution
--   • Resolution-time realism
--   • Driver and vehicle workload distribution
--   • Invoice receivables
-- ============================================================


-- ============================================================
-- 1. REFERENTIAL INTEGRITY CHECKS
-- ============================================================

-- Shipments without valid customers
SELECT COUNT(*) AS orphan_shipments_customers
FROM shipments s
LEFT JOIN customers c
    ON s.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- Shipments without valid routes
SELECT COUNT(*) AS orphan_shipments_routes
FROM shipments s
LEFT JOIN routes r
    ON s.route_id = r.route_id
WHERE r.route_id IS NULL;


-- Shipments without valid drivers
SELECT COUNT(*) AS orphan_shipments_drivers
FROM shipments s
LEFT JOIN drivers d
    ON s.driver_id = d.driver_id
WHERE d.driver_id IS NULL;


-- Shipments without valid vehicles
SELECT COUNT(*) AS orphan_shipments_vehicles
FROM shipments s
LEFT JOIN vehicles v
    ON s.vehicle_id = v.vehicle_id
WHERE v.vehicle_id IS NULL;


-- Delivery attempts without shipments
SELECT COUNT(*) AS orphan_delivery_attempts
FROM delivery_attempts da
LEFT JOIN shipments s
    ON da.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;


-- Tracking events without shipments
SELECT COUNT(*) AS orphan_tracking_events
FROM tracking_events te
LEFT JOIN shipments s
    ON te.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;


-- Issues without shipments
SELECT COUNT(*) AS orphan_shipment_issues
FROM shipment_issues si
LEFT JOIN shipments s
    ON si.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;


-- Invoices without shipments
SELECT COUNT(*) AS orphan_invoices
FROM invoices i
LEFT JOIN shipments s
    ON i.shipment_id = s.shipment_id
WHERE s.shipment_id IS NULL;



-- ============================================================
-- 2. BASIC DATA QUALITY CHECKS
-- ============================================================

-- Duplicate tracking numbers
SELECT
    tracking_number,
    COUNT(*) AS duplicate_count
FROM shipments
GROUP BY tracking_number
HAVING COUNT(*) > 1;


-- Invalid delivery dates
SELECT COUNT(*) AS invalid_delivery_dates
FROM shipments
WHERE actual_delivery_date < shipment_date;


-- Negative financial values
SELECT COUNT(*) AS invalid_financial_values
FROM shipments
WHERE shipping_fee < 0
   OR delivery_cost < 0;


-- Invalid package weights
SELECT COUNT(*) AS invalid_package_weights
FROM shipments
WHERE package_weight_kg <= 0;


-- Delivered shipments without delivery dates
SELECT COUNT(*) AS delivered_without_date
FROM shipments
WHERE shipment_status = 'Delivered'
  AND actual_delivery_date IS NULL;


-- Non-delivered shipments with delivery dates
SELECT COUNT(*) AS undelivered_with_date
FROM shipments
WHERE shipment_status <> 'Delivered'
  AND actual_delivery_date IS NOT NULL;

-- ============================================================
-- 3. ISSUE TYPE DISTRIBUTION REFINEMENT
-- ============================================================
-- The original synthetic issue distribution produced patterns
-- that looked too artificial.
--
-- Reassign issue types using deterministic hash-based weights
-- to create more realistic variation while keeping results
-- reproducible.
-- ============================================================

UPDATE shipment_issues
SET issue_type =
    CASE
        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 1650
            THEN 'Vehicle Breakdown'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 3290
            THEN 'Hub Delay'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 4900
            THEN 'Weather Delay'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 6500
            THEN 'Traffic Delay'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 7920
            THEN 'Sorting Delay'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 8540
            THEN 'Wrong Address'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 9120
            THEN 'Customer Unavailable'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 9600
            THEN 'Delivery Refused'

        WHEN MOD(
            ABS(hashtext('issue-' || issue_id::text))::bigint,
            10000
        ) < 9870
            THEN 'Damaged Package'

        ELSE 'Access Restricted'
    END;

-- Validate issue distribution

SELECT
    issue_type,
    COUNT(*) AS issue_count,
    ROUND(
        COUNT(*) * 100.0
        / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM shipment_issues
GROUP BY issue_type
ORDER BY issue_count DESC;


-- ============================================================
-- 4. ISSUE RESOLUTION TIME REFINEMENT
-- ============================================================
-- Resolution times are varied by issue severity.
--
-- More complex issues such as damaged packages and vehicle
-- breakdowns take longer to resolve than traffic delays,
-- customer availability issues or access restrictions.
-- ============================================================

UPDATE shipment_issues
SET resolved_date =
    issue_date +
    (
        CASE
            WHEN issue_type = 'Damaged Package'
                THEN 4
                    + MOD(
                        ABS(
                            hashtext(
                                'resolve-' || issue_id::text
                            )::bigint
                        ),
                        3
                    )

            WHEN issue_type = 'Vehicle Breakdown'
                THEN 3
                    + MOD(
                        ABS(
                            hashtext(
                                'resolve-' || issue_id::text
                            )::bigint
                        ),
                        3
                    )

            WHEN issue_type = 'Weather Delay'
                THEN 2
                    + MOD(
                        ABS(
                            hashtext(
                                'resolve-' || issue_id::text
                            )::bigint
                        ),
                        3
                    )

            WHEN issue_type IN (
                'Hub Delay',
                'Wrong Address'
            )
                THEN 1
                    + MOD(
                        ABS(
                            hashtext(
                                'resolve-' || issue_id::text
                            )::bigint
                        ),
                        3
                    )

            WHEN issue_type IN (
                'Traffic Delay',
                'Sorting Delay',
                'Customer Unavailable',
                'Delivery Refused',
                'Access Restricted'
            )
                THEN 1
                    + MOD(
                        ABS(
                            hashtext(
                                'resolve-' || issue_id::text
                            )::bigint
                        ),
                        2
                    )

            ELSE 2
        END
    ) * INTERVAL '1 day'

WHERE resolution_status = 'Resolved';


-- Open/unresolved issues should not have a resolved date

UPDATE shipment_issues
SET resolved_date = NULL
WHERE resolution_status <> 'Resolved';


-- Validate average resolution time by issue type

SELECT
    issue_type,
    COUNT(*) AS resolved_issues,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (resolved_date - issue_date)
            ) / 86400.0
        ),
        2
    ) AS avg_resolution_days
FROM shipment_issues
WHERE resolution_status = 'Resolved'
  AND resolved_date IS NOT NULL
GROUP BY issue_type
ORDER BY avg_resolution_days DESC;


-- ============================================================
-- 5. DELIVERY ATTEMPT REFINEMENT
-- ============================================================
-- Rebuild delivery attempts so that:
--   • Most delivered shipments succeed on the first attempt
--   • Some require a second or third attempt
--   • Failed deliveries remain unsuccessful
-- ============================================================

DELETE FROM delivery_attempts;


WITH attempt_source AS (
    SELECT
        s.shipment_id,
        s.driver_id,
        s.pickup_date,
        s.shipment_status,

        CASE
            WHEN s.shipment_status = 'Delivered' THEN
                CASE
                    WHEN MOD(
                        ABS(
                            hashtext(
                                'attempt-'
                                || s.shipment_id::text
                            )::bigint
                        ),
                        100
                    ) < 80
                        THEN 1

                    WHEN MOD(
                        ABS(
                            hashtext(
                                'attempt-'
                                || s.shipment_id::text
                            )::bigint
                        ),
                        100
                    ) < 96
                        THEN 2

                    ELSE 3
                END

            WHEN s.shipment_status = 'Failed Delivery' THEN
                1
                + MOD(
                    ABS(
                        hashtext(
                            'failed-attempt-'
                            || s.shipment_id::text
                        )::bigint
                    ),
                    3
                )::int
        END AS attempt_count

    FROM shipments s

    WHERE s.shipment_status IN (
        'Delivered',
        'Failed Delivery'
    )
)

INSERT INTO delivery_attempts (
    shipment_id,
    driver_id,
    attempt_number,
    attempt_date,
    attempt_status,
    failure_reason,
    recipient_name
)

SELECT
    a.shipment_id,
    a.driver_id,
    gs.attempt_number,

    COALESCE(
        a.pickup_date,
        CURRENT_DATE
    )::timestamp
        + ((gs.attempt_number - 1) * INTERVAL '1 day')
        + INTERVAL '10 hours',

    CASE
        WHEN a.shipment_status = 'Delivered'
             AND gs.attempt_number = a.attempt_count
            THEN 'Successful'

        ELSE 'Failed'
    END AS attempt_status,

    CASE
        WHEN a.shipment_status = 'Delivered'
             AND gs.attempt_number = a.attempt_count
            THEN NULL

        ELSE
            CASE
                WHEN MOD(
                    ABS(
                        hashtext(
                            'failure-'
                            || a.shipment_id::text
                            || '-'
                            || gs.attempt_number::text
                        )::bigint
                    ),
                    100
                ) < 32
                    THEN 'Customer Unavailable'

                WHEN MOD(
                    ABS(
                        hashtext(
                            'failure-'
                            || a.shipment_id::text
                            || '-'
                            || gs.attempt_number::text
                        )::bigint
                    ),
                    100
                ) < 54
                    THEN 'Wrong Address'

                WHEN MOD(
                    ABS(
                        hashtext(
                            'failure-'
                            || a.shipment_id::text
                            || '-'
                            || gs.attempt_number::text
                        )::bigint
                    ),
                    100
                ) < 72
                    THEN 'Recipient Unreachable'

                WHEN MOD(
                    ABS(
                        hashtext(
                            'failure-'
                            || a.shipment_id::text
                            || '-'
                            || gs.attempt_number::text
                        )::bigint
                    ),
                    100
                ) < 84
                    THEN 'Access Restricted'

                WHEN MOD(
                    ABS(
                        hashtext(
                            'failure-'
                            || a.shipment_id::text
                            || '-'
                            || gs.attempt_number::text
                        )::bigint
                    ),
                    100
                ) < 94
                    THEN 'Delivery Refused'

                ELSE 'Customer Requested Reschedule'
            END
    END AS failure_reason,

    CASE
        WHEN a.shipment_status = 'Delivered'
             AND gs.attempt_number = a.attempt_count
            THEN 'Recipient ' || a.shipment_id

        ELSE NULL
    END AS recipient_name

FROM attempt_source a

CROSS JOIN LATERAL
    generate_series(
        1,
        a.attempt_count
    ) AS gs(attempt_number);


-- ============================================================
-- VALIDATE FIRST-ATTEMPT SUCCESS RATE
-- ============================================================

SELECT
    ROUND(
        100.0
        * COUNT(*) FILTER (
            WHERE attempt_number = 1
              AND attempt_status = 'Successful'
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE attempt_number = 1
            ),
            0
        ),
        2
    ) AS first_attempt_success_rate
FROM delivery_attempts;

-- ============================================================
-- VALIDATE FAILURE REASON DISTRIBUTION
-- ============================================================

SELECT
    failure_reason,
    COUNT(*) AS failed_attempts,
    ROUND(
        COUNT(*) * 100.0
        /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM delivery_attempts
WHERE attempt_status = 'Failed'
GROUP BY failure_reason
ORDER BY failed_attempts DESC;


-- ============================================================
-- 6. DRIVER WORKLOAD REDISTRIBUTION
-- ============================================================
-- Reassign shipments across active drivers based at the
-- shipment route's origin hub.
--
-- Hash-based assignment avoids sequential/modulo clustering
-- while remaining reproducible.
-- ============================================================

WITH active_drivers AS (
    SELECT
        driver_id,
        assigned_hub_id,

        ROW_NUMBER() OVER (
            PARTITION BY assigned_hub_id
            ORDER BY driver_id
        ) AS driver_rank,

        COUNT(*) OVER (
            PARTITION BY assigned_hub_id
        ) AS drivers_at_hub

    FROM drivers
    WHERE driver_status = 'Active'
),

driver_assignments AS (
    SELECT
        s.shipment_id,
        ad.driver_id

    FROM shipments s

    JOIN routes r
        ON s.route_id = r.route_id

    JOIN active_drivers ad
        ON ad.assigned_hub_id = r.origin_hub_id
       AND ad.driver_rank =
            1 + MOD(
                ABS(
                    hashtext(
                        'driver-assignment-'
                        || s.shipment_id::text
                    )::bigint
                ),
                ad.drivers_at_hub
            )::int
)

UPDATE shipments s
SET driver_id = da.driver_id
FROM driver_assignments da
WHERE s.shipment_id = da.shipment_id;


-- Validate driver utilization

SELECT
    COUNT(DISTINCT driver_id) AS drivers_utilized,
    COUNT(*) AS total_shipments,
    ROUND(
        COUNT(*)::numeric
        / NULLIF(
            COUNT(DISTINCT driver_id),
            0
        ),
        2
    ) AS avg_shipments_per_driver
FROM shipments;


-- Review workload by driver

SELECT
    d.driver_id,
    d.driver_name,
    h.hub_name,
    COUNT(s.shipment_id) AS assigned_shipments

FROM drivers d

JOIN hubs h
    ON d.assigned_hub_id = h.hub_id

LEFT JOIN shipments s
    ON d.driver_id = s.driver_id

WHERE d.driver_status = 'Active'

GROUP BY
    d.driver_id,
    d.driver_name,
    h.hub_name

ORDER BY assigned_shipments DESC;


-- ============================================================
-- 7. VEHICLE WORKLOAD REDISTRIBUTION
-- ============================================================
-- Reassign shipments across active vehicles located at the
-- route's origin hub.
--
-- This produces a more realistic fleet-utilization pattern
-- and prevents excessive concentration on a few vehicles.
-- ============================================================

WITH active_vehicles AS (
    SELECT
        vehicle_id,
        assigned_hub_id,

        ROW_NUMBER() OVER (
            PARTITION BY assigned_hub_id
            ORDER BY vehicle_id
        ) AS vehicle_rank,

        COUNT(*) OVER (
            PARTITION BY assigned_hub_id
        ) AS vehicles_at_hub

    FROM vehicles
    WHERE vehicle_status = 'Active'
),

vehicle_assignments AS (
    SELECT
        s.shipment_id,
        av.vehicle_id

    FROM shipments s

    JOIN routes r
        ON s.route_id = r.route_id

    JOIN active_vehicles av
        ON av.assigned_hub_id = r.origin_hub_id
       AND av.vehicle_rank =
            1 + MOD(
                ABS(
                    hashtext(
                        'vehicle-assignment-'
                        || s.shipment_id::text
                    )::bigint
                ),
                av.vehicles_at_hub
            )::int
)

UPDATE shipments s
SET vehicle_id = va.vehicle_id
FROM vehicle_assignments va
WHERE s.shipment_id = va.shipment_id;


-- Validate fleet utilization

SELECT
    COUNT(DISTINCT vehicle_id) AS vehicles_utilized,
    COUNT(*) AS total_shipments,
    ROUND(
        COUNT(*)::numeric
        / NULLIF(
            COUNT(DISTINCT vehicle_id),
            0
        ),
        2
    ) AS avg_shipments_per_vehicle
FROM shipments;


-- Average workload by vehicle type

SELECT
    v.vehicle_type,

    COUNT(DISTINCT s.vehicle_id) AS vehicles_utilized,

    COUNT(s.shipment_id) AS total_shipments,

    ROUND(
        COUNT(s.shipment_id)::numeric
        / NULLIF(
            COUNT(DISTINCT s.vehicle_id),
            0
        ),
        2
    ) AS avg_shipments_per_vehicle

FROM shipments s

JOIN vehicles v
    ON s.vehicle_id = v.vehicle_id

GROUP BY v.vehicle_type

ORDER BY avg_shipments_per_vehicle DESC;


-- ============================================================
-- 8. RECEIVABLES AND PAYMENT REFINEMENT
-- ============================================================
-- Recalculate payment values so that:
--   • Paid invoices have no outstanding balance
--   • Partially Paid invoices have realistic partial payments
--   • Pending and Overdue invoices remain fully outstanding
-- ============================================================

UPDATE invoices
SET
    amount_paid =
        CASE
            WHEN payment_status = 'Paid'
                THEN total_amount

            WHEN payment_status = 'Partially Paid'
                THEN ROUND(
                    (
                        total_amount
                        *
                        (
                            0.40
                            +
                            MOD(
                                ABS(
                                    hashtext(
                                        'partial-payment-'
                                        || invoice_id::text
                                    )::bigint
                                ),
                                41
                            ) / 100.0
                        )
                    )::numeric,
                    2
                )

            ELSE 0
        END,

    outstanding_balance =
        CASE
            WHEN payment_status = 'Paid'
                THEN 0

            WHEN payment_status = 'Partially Paid'
                THEN total_amount
                    -
                    ROUND(
                        (
                            total_amount
                            *
                            (
                                0.40
                                +
                                MOD(
                                    ABS(
                                        hashtext(
                                            'partial-payment-'
                                            || invoice_id::text
                                        )::bigint
                                    ),
                                    41
                                ) / 100.0
                            )
                        )::numeric,
                        2
                    )

            ELSE total_amount
        END;


-- ============================================================
-- PAYMENT DATE CONSISTENCY
-- ============================================================

UPDATE invoices
SET paid_date =
    invoice_date
    + 1
    + MOD(
        ABS(
            hashtext(
                'paid-date-' || invoice_id::text
            )::bigint
        ),
        30
    )::int
WHERE payment_status = 'Paid';


UPDATE invoices
SET paid_date = NULL
WHERE payment_status <> 'Paid';


-- ============================================================
-- 9. FINAL DATA QUALITY SUMMARY
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM shipments) AS total_shipments,

    (
        SELECT COUNT(*)
        FROM shipments
        WHERE shipment_status = 'Delivered'
    ) AS delivered_shipments,

    (
        SELECT COUNT(DISTINCT driver_id)
        FROM shipments
    ) AS drivers_utilized,

    (
        SELECT COUNT(DISTINCT vehicle_id)
        FROM shipments
    ) AS vehicles_utilized,

    (
        SELECT COUNT(*)
        FROM shipment_issues
    ) AS total_issues,

    (
        SELECT COUNT(*)
        FROM shipment_issues
        WHERE resolution_status = 'Resolved'
    ) AS resolved_issues,

    (
        SELECT COUNT(*)
        FROM shipment_issues
        WHERE resolution_status <> 'Resolved'
    ) AS unresolved_issues,

    (
        SELECT ROUND(SUM(outstanding_balance), 2)
        FROM invoices
    ) AS outstanding_receivables;


