-- ============================================================
-- Logistics Operations Performance Dashboard
-- Synthetic Data Generation
-- PostgreSQL
-- ============================================================
-- This script generates fictional logistics data for portfolio
-- and analytical purposes only.
-- ============================================================


-- ============================================================
-- 1. HUBS
-- ============================================================

INSERT INTO hubs (
    hub_name,
    city,
    state,
    hub_type,
    opening_date,
    capacity_per_day,
    hub_status
)
VALUES
('Lagos Central Hub', 'Lagos', 'Lagos', 'Regional', '2019-01-15', 1900, 'Active'),
('Lagos Island Hub', 'Lagos', 'Lagos', 'Local', '2020-03-10', 320, 'Active'),
('Abuja Central Hub', 'Abuja', 'FCT', 'Regional', '2019-06-20', 850, 'Active'),
('Port Harcourt Hub', 'Port Harcourt', 'Rivers', 'Regional', '2020-02-18', 650, 'Active'),
('Ibadan Hub', 'Ibadan', 'Oyo', 'Regional', '2020-08-12', 480, 'Active'),
('Benin Hub', 'Benin City', 'Edo', 'Local', '2021-01-11', 270, 'Active'),
('Enugu Hub', 'Enugu', 'Enugu', 'Local', '2021-05-24', 250, 'Active'),
('Kano Hub', 'Kano', 'Kano', 'Regional', '2020-09-14', 240, 'Active'),
('Kaduna Hub', 'Kaduna', 'Kaduna', 'Local', '2021-03-18', 200, 'Active'),
('Abeokuta Hub', 'Abeokuta', 'Ogun', 'Local', '2022-01-10', 180, 'Active'),
('Ilorin Hub', 'Ilorin', 'Kwara', 'Local', '2022-04-15', 160, 'Active'),
('Owerri Hub', 'Owerri', 'Imo', 'Local', '2022-07-21', 150, 'Active');


-- ============================================================
-- 2. CUSTOMERS
-- ============================================================

INSERT INTO customers (
    customer_name,
    customer_type,
    email,
    phone_number,
    city,
    state,
    registration_date,
    customer_status
)
SELECT
    'Customer ' || LPAD(g::text, 4, '0'),

    CASE MOD(ABS(hashtext('type-' || g::text)), 10)
        WHEN 0 THEN 'Corporate'
        WHEN 1 THEN 'Corporate'
        WHEN 2 THEN 'SME'
        WHEN 3 THEN 'SME'
        WHEN 4 THEN 'SME'
        ELSE 'Individual'
    END,

    'customer' || g || '@example.com',

    '+23480' || LPAD(
        MOD(ABS(hashtext('phone-' || g::text))::bigint, 100000000)::text,
        8,
        '0'
    ),

    CASE MOD(g, 8)
        WHEN 0 THEN 'Lagos'
        WHEN 1 THEN 'Abuja'
        WHEN 2 THEN 'Port Harcourt'
        WHEN 3 THEN 'Ibadan'
        WHEN 4 THEN 'Benin City'
        WHEN 5 THEN 'Enugu'
        WHEN 6 THEN 'Kano'
        ELSE 'Kaduna'
    END,

    CASE MOD(g, 8)
        WHEN 0 THEN 'Lagos'
        WHEN 1 THEN 'FCT'
        WHEN 2 THEN 'Rivers'
        WHEN 3 THEN 'Oyo'
        WHEN 4 THEN 'Edo'
        WHEN 5 THEN 'Enugu'
        WHEN 6 THEN 'Kano'
        ELSE 'Kaduna'
    END,

    DATE '2022-01-01'
        + MOD(ABS(hashtext('reg-' || g::text)), 730),

    CASE
        WHEN MOD(ABS(hashtext('cust-status-' || g::text)), 100) < 95
            THEN 'Active'
        ELSE 'Inactive'
    END

FROM generate_series(1, 2500) AS g;


-- ============================================================
-- 3. DRIVERS
-- ============================================================

INSERT INTO drivers (
    driver_name,
    phone_number,
    email,
    hire_date,
    license_number,
    driver_status,
    assigned_hub_id
)
SELECT
    (
        ARRAY[
            'Samuel Adebayo',
            'Tunde Umar',
            'John Okafor',
            'Ahmed Lawal',
            'Victor Abubakar',
            'Victor Eze',
            'John Nwosu',
            'Ahmed Balogun',
            'Tunde Adeyemi',
            'Samuel Ojo'
        ]
    )[1 + MOD(g - 1, 10)],

    '+23481' || LPAD(g::text, 8, '0'),

    'driver' || g || '@logisticsdemo.com',

    DATE '2020-01-01'
        + MOD(ABS(hashtext('hire-' || g::text)), 1200),

    'LIC-' || LPAD(g::text, 5, '0'),

    CASE
        WHEN MOD(ABS(hashtext('driver-status-' || g::text)), 100) < 85
            THEN 'Active'
        WHEN MOD(ABS(hashtext('driver-status-' || g::text)), 100) < 94
            THEN 'On Leave'
        ELSE 'Inactive'
    END,

    1 + MOD(ABS(hashtext('driver-hub-' || g::text)), 12)

FROM generate_series(1, 180) AS g;


-- ============================================================
-- 4. VEHICLES
-- ============================================================

INSERT INTO vehicles (
    registration_number,
    vehicle_type,
    make,
    model,
    capacity_kg,
    acquisition_date,
    vehicle_status,
    assigned_hub_id
)
SELECT
    'LG-' || LPAD(g::text, 4, '0'),

    CASE MOD(ABS(hashtext('vehicle-type-' || g::text)), 10)
        WHEN 0 THEN 'Truck'
        WHEN 1 THEN 'Truck'
        WHEN 2 THEN 'Van'
        WHEN 3 THEN 'Van'
        WHEN 4 THEN 'Van'
        ELSE 'Motorcycle'
    END,

    CASE MOD(g, 5)
        WHEN 0 THEN 'Toyota'
        WHEN 1 THEN 'Ford'
        WHEN 2 THEN 'Isuzu'
        WHEN 3 THEN 'Honda'
        ELSE 'Mercedes-Benz'
    END,

    'Model-' || LPAD(g::text, 3, '0'),

    CASE
        WHEN MOD(ABS(hashtext('vehicle-type-' || g::text)), 10) <= 1 THEN 5000
        WHEN MOD(ABS(hashtext('vehicle-type-' || g::text)), 10) <= 4 THEN 1500
        ELSE 150
    END,

    DATE '2019-01-01'
        + MOD(ABS(hashtext('vehicle-date-' || g::text)), 1500),

    CASE
        WHEN MOD(ABS(hashtext('vehicle-status-' || g::text)), 100) < 82
            THEN 'Active'
        WHEN MOD(ABS(hashtext('vehicle-status-' || g::text)), 100) < 93
            THEN 'Maintenance'
        ELSE 'Inactive'
    END,

    1 + MOD(ABS(hashtext('vehicle-hub-' || g::text)), 12)

FROM generate_series(1, 120) AS g;


-- ============================================================
-- 5. ROUTES
-- ============================================================

INSERT INTO routes (
    route_name,
    origin_hub_id,
    destination_hub_id,
    distance_km,
    standard_delivery_days,
    route_status
)
VALUES
('Lagos Central → Abuja',          1, 3, 760, 3, 'Active'),
('Lagos Central → Ibadan',         1, 5, 135, 1, 'Active'),
('Abuja → Lagos Central',          3, 1, 760, 3, 'Active'),
('Port Harcourt → Lagos Central',  4, 1, 615, 3, 'Active'),
('Ibadan → Lagos Central',         5, 1, 135, 1, 'Active'),
('Lagos Central → Abeokuta',       1,10, 105, 1, 'Active'),
('Abuja → Kaduna',                 3, 9, 190, 1, 'Active'),
('Benin → Port Harcourt',          6, 4, 300, 2, 'Active'),
('Ibadan → Ilorin',                5,11, 170, 1, 'Active'),
('Abuja → Ilorin',                 3,11, 460, 2, 'Active'),
('Abuja → Kano',                   3, 8, 450, 2, 'Active'),
('Benin → Lagos Central',          6, 1, 320, 2, 'Active'),
('Enugu → Abuja',                  7, 3, 460, 2, 'Active'),
('Kaduna → Abuja',                 9, 3, 190, 1, 'Active'),
('Kano → Kaduna',                  8, 9, 230, 2, 'Active'),
('Lagos Central → Benin',          1, 6, 320, 2, 'Active'),
('Lagos Central → Enugu',          1, 7, 560, 2, 'Active'),
('Lagos Central → Port Harcourt',  1, 4, 615, 3, 'Active'),
('Lagos Island → Abeokuta',        2,10, 110, 1, 'Active'),
('Lagos Island → Abuja',           2, 3, 765, 3, 'Active'),
('Lagos Island → Ibadan',          2, 5, 140, 1, 'Active'),
('Port Harcourt → Enugu',          4, 7, 240, 2, 'Active'),
('Port Harcourt → Owerri',         4,12, 100, 1, 'Active'),
('Abuja → Enugu',                  3, 7, 460, 2, 'Active'),
('Enugu → Port Harcourt',          7, 4, 240, 2, 'Active'),
('Ibadan → Abeokuta',              5,10,  80, 1, 'Active'),
('Kano → Abuja',                   8, 3, 450, 2, 'Active'),
('Lagos Central → Ilorin',         1,11, 300, 2, 'Active'),
('Lagos Central → Kano',           1, 8,1140, 4, 'Active'),
('Port Harcourt → Benin',          4, 6, 300, 2, 'Active');


-- ============================================================
-- 6. SHIPMENTS
-- ============================================================
-- Generates 100,000 shipments between Jan 2024 and Aug 2026.
-- Hash-based logic makes the dataset deterministic while still
-- producing realistic variation in dates, status and values.
-- Nov/Dec 2024 and Nov/Dec 2025 receive additional volume to
-- represent seasonal logistics demand.
-- ============================================================

WITH shipment_base AS (
    SELECT
        g,

        -- Customer
        1 + MOD(
            ABS(hashtext('customer-' || g::text))::bigint,
            2500
        )::int AS customer_id,

        -- Route
        1 + MOD(
            ABS(hashtext('route-' || g::text))::bigint,
            30
        )::int AS route_id,

        -- Initial driver assignment.
        -- Later QA script aligns drivers to route origin hubs.
        1 + MOD(
            ABS(hashtext('driver-' || g::text))::bigint,
            180
        )::int AS driver_id,

        -- Initial vehicle assignment.
        -- Later QA script aligns vehicles to route origin hubs.
        1 + MOD(
            ABS(hashtext('vehicle-' || g::text))::bigint,
            120
        )::int AS vehicle_id,

        MOD(
            ABS(hashtext('season-' || g::text))::bigint,
            100
        ) AS season_score,

        MOD(
            ABS(hashtext('status-' || g::text))::bigint,
            10000
        ) AS status_score,

        MOD(
            ABS(hashtext('priority-' || g::text))::bigint,
            100
        ) AS priority_score

    FROM generate_series(1, 100000) AS g
),

dated_shipments AS (
    SELECT
        sb.*,

        CASE
            -- Additional Nov/Dec 2024 traffic
            WHEN season_score < 6 THEN
                DATE '2024-11-01'
                + MOD(
                    ABS(hashtext('season-2024-' || g::text))::bigint,
                    61
                )::int

            -- Additional Nov/Dec 2025 traffic
            WHEN season_score < 12 THEN
                DATE '2025-11-01'
                + MOD(
                    ABS(hashtext('season-2025-' || g::text))::bigint,
                    61
                )::int

            -- Normal traffic: Jan 2024 through Aug 2026
            ELSE
                DATE '2024-01-01'
                + MOD(
                    ABS(hashtext('shipment-date-' || g::text))::bigint,
                    974
                )::int
        END AS shipment_date

    FROM shipment_base sb
),

shipment_details AS (
    SELECT
        ds.*,
        r.standard_delivery_days,

        CASE
            WHEN status_score < 9385
                THEN 'Delivered'

            WHEN status_score < 9685
                THEN 'Failed Delivery'

            WHEN status_score < 9850
                THEN 'In Transit'

            ELSE 'Cancelled'
        END AS shipment_status

    FROM dated_shipments ds
    JOIN routes r
        ON r.route_id = ds.route_id
)

INSERT INTO shipments (
    tracking_number,
    customer_id,
    route_id,
    driver_id,
    vehicle_id,
    shipment_date,
    pickup_date,
    expected_delivery_date,
    actual_delivery_date,
    shipment_status,
    shipment_type,
    delivery_priority,
    package_weight_kg,
    shipping_fee,
    delivery_cost
)
SELECT
    'SHP-' || LPAD(g::text, 7, '0'),

    customer_id,
    route_id,
    driver_id,
    vehicle_id,
    shipment_date,

    -- Most shipments are picked up same day or next day
    shipment_date
        + MOD(
            ABS(hashtext('pickup-' || g::text))::bigint,
            2
        )::int,

    -- SLA date based on route distance
    shipment_date + standard_delivery_days,

    CASE
        WHEN shipment_status = 'Delivered' THEN

            CASE
                -- Approximately 85% of delivered shipments
                -- initially meet SLA.
                WHEN MOD(
                    ABS(hashtext('sla-' || g::text))::bigint,
                    10000
                ) < 8524
                THEN shipment_date + standard_delivery_days

                -- Late deliveries arrive 1–3 days after SLA.
                ELSE shipment_date
                     + standard_delivery_days
                     + 1
                     + MOD(
                         ABS(hashtext('late-' || g::text))::bigint,
                         3
                     )::int
            END

        ELSE NULL
    END,

    shipment_status,

    CASE MOD(
        ABS(hashtext('shipment-type-' || g::text))::bigint,
        20
    )
        WHEN 0 THEN 'Bulk'
        WHEN 1 THEN 'Fragile'
        WHEN 2 THEN 'Fragile'
        WHEN 3 THEN 'Document'
        WHEN 4 THEN 'Document'
        WHEN 5 THEN 'Document'
        WHEN 6 THEN 'Document'
        WHEN 7 THEN 'Document'
        ELSE 'Parcel'
    END,

    CASE
        WHEN priority_score < 60 THEN 'Standard'
        WHEN priority_score < 90 THEN 'Express'
        ELSE 'Economy'
    END,

    -- Package weight: approximately 0.5–50 kg
    ROUND(
        (
            0.50
            + MOD(
                ABS(hashtext('weight-' || g::text))::bigint,
                4950
            ) / 100.0
        )::numeric,
        2
    ),

    -- Shipping fee: approximately ₦3,500–₦13,000
    ROUND(
        (
            3500
            + MOD(
                ABS(hashtext('fee-' || g::text))::bigint,
                950000
            ) / 100.0
        )::numeric,
        2
    ),

    -- Delivery cost: approximately ₦2,500–₦7,500
    ROUND(
        (
            2500
            + MOD(
                ABS(hashtext('cost-' || g::text))::bigint,
                500000
            ) / 100.0
        )::numeric,
        2
    )

FROM shipment_details;


-- ============================================================
-- SHIPMENT VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS total_shipments,
    MIN(shipment_date) AS first_shipment_date,
    MAX(shipment_date) AS last_shipment_date
FROM shipments;


SELECT
    shipment_status,
    COUNT(*) AS shipment_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM shipments
GROUP BY shipment_status
ORDER BY shipment_count DESC;


-- ============================================================
-- 7. TRACKING EVENTS
-- ============================================================
-- Creates approximately 4–8 tracking events per shipment.
-- ============================================================

WITH event_source AS (
    SELECT
        s.shipment_id,
        s.shipment_date,
        s.shipment_status,
        r.origin_hub_id,
        r.destination_hub_id,
        4 + MOD(
            ABS(hashtext('event-count-' || s.shipment_id::text)::bigint),
            5
        )::int AS event_count
    FROM shipments s
    JOIN routes r
        ON r.route_id = s.route_id
)

INSERT INTO tracking_events (
    shipment_id,
    hub_id,
    event_type,
    event_timestamp,
    event_status,
    remarks
)
SELECT
    es.shipment_id,

    CASE
        WHEN e.event_no <= 2
            THEN es.origin_hub_id

        WHEN e.event_no = es.event_count
            THEN es.destination_hub_id

        ELSE
            1 + MOD(
                ABS(
                    hashtext(
                        'event-hub-'
                        || es.shipment_id::text
                        || '-'
                        || e.event_no::text
                    )::bigint
                ),
                12
            )::int
    END AS hub_id,

    CASE
        WHEN e.event_no = 1
            THEN 'Shipment Created'

        WHEN e.event_no = 2
            THEN 'Picked Up'

        WHEN e.event_no = es.event_count
             AND es.shipment_status = 'Delivered'
            THEN 'Delivered'

        WHEN e.event_no = es.event_count
             AND es.shipment_status = 'Failed Delivery'
            THEN 'Delivery Failed'

        WHEN e.event_no = es.event_count
             AND es.shipment_status = 'Cancelled'
            THEN 'Cancelled'

        WHEN e.event_no = es.event_count
             AND es.shipment_status = 'In Transit'
            THEN 'In Transit'

        WHEN MOD(e.event_no, 2) = 0
            THEN 'Arrived at Hub'

        ELSE 'In Transit'
    END AS event_type,

    es.shipment_date::timestamp
        + ((e.event_no - 1) * INTERVAL '12 hours')
        + (
            MOD(
                ABS(
                    hashtext(
                        'event-hour-'
                        || es.shipment_id::text
                        || '-'
                        || e.event_no::text
                    )::bigint
                ),
                10
            ) * INTERVAL '1 hour'
        ) AS event_timestamp,

    CASE
        WHEN e.event_no = es.event_count
            THEN es.shipment_status
        ELSE 'Completed'
    END AS event_status,

    CASE
        WHEN e.event_no = es.event_count
             AND es.shipment_status = 'Failed Delivery'
            THEN 'Delivery attempt unsuccessful'
        ELSE NULL
    END AS remarks

FROM event_source es

CROSS JOIN LATERAL
    generate_series(1, es.event_count) AS e(event_no);



-- ============================================================
-- 8. DELIVERY ATTEMPTS
-- ============================================================
-- Delivered shipments can succeed on attempts 1–3.
-- Failed deliveries contain unsuccessful attempts only.
-- ============================================================

WITH attempt_source AS (
    SELECT
        s.shipment_id,
        s.driver_id,
        s.pickup_date,
        s.actual_delivery_date,
        s.shipment_status,

        CASE
            WHEN s.shipment_status = 'Delivered' THEN
                CASE
                    WHEN MOD(
                        ABS(hashtext('attempt-' || s.shipment_id::text)::bigint),
                        100
                    ) < 78
                        THEN 1

                    WHEN MOD(
                        ABS(hashtext('attempt-' || s.shipment_id::text)::bigint),
                        100
                    ) < 96
                        THEN 2

                    ELSE 3
                END

            WHEN s.shipment_status = 'Failed Delivery' THEN
                1 + MOD(
                    ABS(hashtext('failed-attempt-' || s.shipment_id::text)::bigint),
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
    END,

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
    END

FROM attempt_source a

CROSS JOIN LATERAL
    generate_series(1, a.attempt_count) AS gs(attempt_number);



-- ============================================================
-- 9. SHIPMENT ISSUES
-- ============================================================
-- Creates exactly 17,360 shipment issues.
-- Issue selection is hash-based rather than simply selecting
-- the first shipment IDs.
-- ============================================================

WITH ranked_shipments AS (
    SELECT
        shipment_id,
        shipment_date,

        ROW_NUMBER() OVER (
            ORDER BY
                hashtext(
                    'issue-selection-' || shipment_id::text
                )
        ) AS issue_rank

    FROM shipments
),

selected_issues AS (
    SELECT
        shipment_id,
        shipment_date,

        MOD(
            ABS(hashtext('issue-type-' || shipment_id::text)::bigint),
            10000
        ) AS issue_score,

        ROW_NUMBER() OVER (
            ORDER BY
                hashtext(
                    'resolution-' || shipment_id::text
                )
        ) AS resolution_rank

    FROM ranked_shipments

    WHERE issue_rank <= 17360
),

issue_details AS (
    SELECT
        *,

        CASE
            WHEN issue_score < 1650
                THEN 'Vehicle Breakdown'

            WHEN issue_score < 3290
                THEN 'Hub Delay'

            WHEN issue_score < 4900
                THEN 'Weather Delay'

            WHEN issue_score < 6500
                THEN 'Traffic Delay'

            WHEN issue_score < 7920
                THEN 'Sorting Delay'

            WHEN issue_score < 8540
                THEN 'Wrong Address'

            WHEN issue_score < 9120
                THEN 'Customer Unavailable'

            WHEN issue_score < 9600
                THEN 'Delivery Refused'

            WHEN issue_score < 9870
                THEN 'Damaged Package'

            ELSE 'Access Restricted'
        END AS issue_type

    FROM selected_issues
)

INSERT INTO shipment_issues (
    shipment_id,
    issue_type,
    issue_description,
    issue_date,
    resolution_status,
    resolved_date
)
SELECT
    shipment_id,

    issue_type,

    issue_type || ' reported during shipment processing',

    shipment_date::timestamp
        + INTERVAL '1 day'
        + (
            MOD(
                ABS(hashtext('issue-hour-' || shipment_id::text)::bigint),
                12
            ) * INTERVAL '1 hour'
        ),

    CASE
        -- Exactly 433 unresolved issues
        WHEN resolution_rank <= 433
            THEN 'Open'
        ELSE 'Resolved'
    END,

    CASE
        WHEN resolution_rank <= 433
            THEN NULL

        ELSE
            shipment_date::timestamp
            + INTERVAL '1 day'

            +
            (
                CASE
                    WHEN issue_type = 'Damaged Package'
                        THEN 4
                            + MOD(
                                ABS(
                                    hashtext(
                                        'resolve-' || shipment_id::text
                                    )::bigint
                                ),
                                3
                            )::int

                    WHEN issue_type = 'Vehicle Breakdown'
                        THEN 3
                            + MOD(
                                ABS(
                                    hashtext(
                                        'resolve-' || shipment_id::text
                                    )::bigint
                                ),
                                3
                            )::int

                    WHEN issue_type = 'Weather Delay'
                        THEN 2
                            + MOD(
                                ABS(
                                    hashtext(
                                        'resolve-' || shipment_id::text
                                    )::bigint
                                ),
                                3
                            )::int

                    WHEN issue_type IN (
                        'Hub Delay',
                        'Wrong Address'
                    )
                        THEN 1
                            + MOD(
                                ABS(
                                    hashtext(
                                        'resolve-' || shipment_id::text
                                    )::bigint
                                ),
                                3
                            )::int

                    ELSE
                        1
                            + MOD(
                                ABS(
                                    hashtext(
                                        'resolve-' || shipment_id::text
                                    )::bigint
                                ),
                                2
                            )::int
                END
            ) * INTERVAL '1 day'
    END

FROM issue_details;



-- ============================================================
-- 10. INVOICES
-- ============================================================
-- Generates invoices for 97,000 shipments.
-- Includes paid, partially paid, pending and overdue invoices.
-- ============================================================

WITH ranked_invoices AS (
    SELECT
        s.*,

        ROW_NUMBER() OVER (
            ORDER BY
                hashtext(
                    'invoice-selection-' || s.shipment_id::text
                )
        ) AS invoice_rank

    FROM shipments s
),

invoice_base AS (
    SELECT
        shipment_id,
        shipment_date,
        shipping_fee,

        ROUND(
            (
                shipping_fee
                *
                (
                    MOD(
                        ABS(
                            hashtext(
                                'discount-' || shipment_id::text
                            )::bigint
                        ),
                        9
                    ) / 100.0
                )
            )::numeric,
            2
        ) AS discount_amount,

        MOD(
            ABS(hashtext('payment-' || shipment_id::text)::bigint),
            100
        ) AS payment_score

    FROM ranked_invoices

    WHERE invoice_rank <= 97000
),

invoice_amounts AS (
    SELECT
        *,

        ROUND(
            (
                (shipping_fee - discount_amount)
                * 0.075
            )::numeric,
            2
        ) AS tax_amount

    FROM invoice_base
),

invoice_totals AS (
    SELECT
        *,

        ROUND(
            (
                shipping_fee
                - discount_amount
                + tax_amount
            )::numeric,
            2
        ) AS total_amount,

        CASE
            WHEN payment_score < 82
                THEN 'Paid'

            WHEN payment_score < 92
                THEN 'Overdue'

            WHEN payment_score < 98
                THEN 'Partially Paid'

            ELSE 'Pending'
        END AS payment_status

    FROM invoice_amounts
)

INSERT INTO invoices (
    shipment_id,
    invoice_date,
    subtotal,
    discount_amount,
    tax_amount,
    total_amount,
    payment_status,
    payment_method,
    paid_date,
    amount_paid,
    outstanding_balance
)
SELECT
    shipment_id,

    shipment_date,

    shipping_fee,

    discount_amount,

    tax_amount,

    total_amount,

    payment_status,

    CASE
        WHEN payment_status = 'Paid'
            THEN (
                ARRAY[
                    'Bank Transfer',
                    'Card',
                    'Wallet'
                ]
            )[
                1 + MOD(
                    ABS(
                        hashtext(
                            'method-' || shipment_id::text
                        )::bigint
                    ),
                    3
                )::int
            ]

        WHEN payment_status = 'Partially Paid'
            THEN 'Bank Transfer'

        ELSE NULL
    END,

    CASE
        WHEN payment_status = 'Paid'
            THEN shipment_date
                + 1
                + MOD(
                    ABS(
                        hashtext(
                            'paid-date-' || shipment_id::text
                        )::bigint
                    ),
                    30
                )::int

        ELSE NULL
    END,

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
                                    'partial-' || shipment_id::text
                                )::bigint
                            ),
                            41
                        ) / 100.0
                    )
                )::numeric,
                2
            )

        ELSE 0
    END AS amount_paid,

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
                                        'partial-' || shipment_id::text
                                    )::bigint
                                ),
                                41
                            ) / 100.0
                        )
                    )::numeric,
                    2
                )

        ELSE total_amount
    END AS outstanding_balance

FROM invoice_totals;


-- ============================================================
-- FINAL DATASET VALIDATION
-- ============================================================

SELECT 'customers' AS table_name, COUNT(*) AS rows
FROM customers

UNION ALL

SELECT 'hubs', COUNT(*)
FROM hubs

UNION ALL

SELECT 'drivers', COUNT(*)
FROM drivers

UNION ALL

SELECT 'vehicles', COUNT(*)
FROM vehicles

UNION ALL

SELECT 'routes', COUNT(*)
FROM routes

UNION ALL

SELECT 'shipments', COUNT(*)
FROM shipments

UNION ALL

SELECT 'tracking_events', COUNT(*)
FROM tracking_events

UNION ALL

SELECT 'delivery_attempts', COUNT(*)
FROM delivery_attempts

UNION ALL

SELECT 'shipment_issues', COUNT(*)
FROM shipment_issues

UNION ALL

SELECT 'invoices', COUNT(*)
FROM invoices

ORDER BY table_name;
