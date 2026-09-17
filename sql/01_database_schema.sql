-- 1. Customers
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    email VARCHAR(150),
    phone_number VARCHAR(30),
    city VARCHAR(100),
    state VARCHAR(100),
    registration_date DATE NOT NULL,
    customer_status VARCHAR(20) NOT NULL
);

-- 2. Hubs
CREATE TABLE hubs (
    hub_id SERIAL PRIMARY KEY,
    hub_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    hub_type VARCHAR(30) NOT NULL,
    opening_date DATE NOT NULL,
    capacity_per_day INT,
    hub_status VARCHAR(20) NOT NULL
);

-- 3. Drivers
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    driver_name VARCHAR(150) NOT NULL,
    phone_number VARCHAR(30),
    email VARCHAR(150),
    hire_date DATE NOT NULL,
    license_number VARCHAR(50) UNIQUE,
    driver_status VARCHAR(20) NOT NULL,
    assigned_hub_id INT,

    FOREIGN KEY (assigned_hub_id)
        REFERENCES hubs(hub_id)
);

-- 4. Vehicles
CREATE TABLE vehicles (
    vehicle_id SERIAL PRIMARY KEY,
    registration_number VARCHAR(50) UNIQUE NOT NULL,
    vehicle_type VARCHAR(30) NOT NULL,
    make VARCHAR(50),
    model VARCHAR(50),
    capacity_kg DECIMAL(10,2),
    acquisition_date DATE,
    vehicle_status VARCHAR(20) NOT NULL,
    assigned_hub_id INT,

    FOREIGN KEY (assigned_hub_id)
        REFERENCES hubs(hub_id)
);

-- 5. Routes
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_name VARCHAR(150) NOT NULL,
    origin_hub_id INT NOT NULL,
    destination_hub_id INT NOT NULL,
    distance_km DECIMAL(10,2) NOT NULL,
    standard_delivery_days INT NOT NULL,
    route_status VARCHAR(20) NOT NULL,

    FOREIGN KEY (origin_hub_id)
        REFERENCES hubs(hub_id),

    FOREIGN KEY (destination_hub_id)
        REFERENCES hubs(hub_id),

    CHECK (origin_hub_id <> destination_hub_id),
    CHECK (distance_km > 0),
    CHECK (standard_delivery_days > 0)
);

-- 6. Shipments
CREATE TABLE shipments (
    shipment_id SERIAL PRIMARY KEY,
    tracking_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id INT NOT NULL,
    route_id INT NOT NULL,
    driver_id INT,
    vehicle_id INT,
    shipment_date DATE NOT NULL,
    pickup_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,
    shipment_status VARCHAR(30) NOT NULL,
    shipment_type VARCHAR(30) NOT NULL,
    delivery_priority VARCHAR(20) NOT NULL,
    package_weight_kg DECIMAL(10,2) NOT NULL,
    shipping_fee DECIMAL(12,2) NOT NULL,
    delivery_cost DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    FOREIGN KEY (route_id)
        REFERENCES routes(route_id),

    FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    FOREIGN KEY (vehicle_id)
        REFERENCES vehicles(vehicle_id),

    CHECK (package_weight_kg > 0),
    CHECK (shipping_fee >= 0),
    CHECK (delivery_cost >= 0)
);

-- 7. Tracking Events
CREATE TABLE tracking_events (
    event_id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL,
    hub_id INT,
    event_type VARCHAR(50) NOT NULL,
    event_timestamp TIMESTAMP NOT NULL,
    event_status VARCHAR(30),
    remarks VARCHAR(255),

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(shipment_id),

    FOREIGN KEY (hub_id)
        REFERENCES hubs(hub_id)
);

-- 8. Delivery Attempts
CREATE TABLE delivery_attempts (
    attempt_id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL,
    driver_id INT,
    attempt_number INT NOT NULL,
    attempt_date TIMESTAMP NOT NULL,
    attempt_status VARCHAR(30) NOT NULL,
    failure_reason VARCHAR(100),
    recipient_name VARCHAR(150),

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(shipment_id),

    FOREIGN KEY (driver_id)
        REFERENCES drivers(driver_id),

    CHECK (attempt_number > 0)
);

-- 9. Shipment Issues
CREATE TABLE shipment_issues (
    issue_id SERIAL PRIMARY KEY,
    shipment_id INT NOT NULL,
    issue_type VARCHAR(50) NOT NULL,
    issue_description VARCHAR(255),
    issue_date TIMESTAMP NOT NULL,
    resolution_status VARCHAR(30) NOT NULL,
    resolved_date TIMESTAMP,

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(shipment_id)
);

-- 10. Invoices
CREATE TABLE invoices (
    invoice_id SERIAL PRIMARY KEY,
    shipment_id INT UNIQUE NOT NULL,
    invoice_date DATE NOT NULL,
    subtotal DECIMAL(12,2) NOT NULL,
    discount_amount DECIMAL(12,2) DEFAULT 0,
    tax_amount DECIMAL(12,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_status VARCHAR(30) NOT NULL,
    payment_method VARCHAR(30),
    paid_date DATE,
    amount_paid DECIMAL(12,2),
    outstanding_balance DECIMAL(12,2),

    FOREIGN KEY (shipment_id)
        REFERENCES shipments(shipment_id),

    CHECK (subtotal >= 0),
    CHECK (discount_amount >= 0),
    CHECK (tax_amount >= 0),
    CHECK (total_amount >= 0)
);
