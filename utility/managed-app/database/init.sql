-- Database initialization script
-- This runs independently of the application to seed data

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_name VARCHAR(255) NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_amount DECIMAL(10, 2) NOT NULL DEFAULT 0,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL
);

-- Seed products
INSERT INTO products (name, description, price, stock) VALUES
    ('Wireless Keyboard', 'Ergonomic wireless keyboard with backlight', 79.99, 150),
    ('USB-C Hub', '7-in-1 USB-C hub with HDMI and ethernet', 49.99, 230),
    ('Mechanical Mouse', 'High-precision gaming mouse, 16000 DPI', 59.99, 85),
    ('Monitor Stand', 'Adjustable aluminum monitor stand with USB ports', 129.99, 42),
    ('Webcam HD', '1080p webcam with noise-canceling microphone', 89.99, 110),
    ('Laptop Sleeve', 'Waterproof neoprene sleeve for 15-inch laptops', 29.99, 300),
    ('Desk Lamp', 'LED desk lamp with adjustable color temperature', 44.99, 175),
    ('Cable Management Kit', 'Complete cable organization set', 19.99, 400),
    ('Portable SSD 1TB', 'High-speed external SSD, USB 3.2', 109.99, 65),
    ('Noise Canceling Headphones', 'Over-ear ANC headphones, 30hr battery', 199.99, 55);

-- Seed orders
INSERT INTO orders (customer_name, order_date, total_amount, status) VALUES
    ('Alice Johnson', '2026-05-15', 159.98, 'completed'),
    ('Bob Smith', '2026-05-18', 49.99, 'completed'),
    ('Carol Williams', '2026-05-20', 289.98, 'completed'),
    ('David Brown', '2026-05-25', 79.99, 'processing'),
    ('Eva Martinez', '2026-05-28', 199.99, 'processing'),
    ('Frank Lee', '2026-06-01', 139.98, 'pending'),
    ('Grace Kim', '2026-06-03', 329.97, 'pending'),
    ('Henry Davis', '2026-06-05', 89.99, 'pending');

-- Seed order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 79.99),
    (1, 2, 1, 49.99),
    (1, 8, 1, 19.99),
    (2, 2, 1, 49.99),
    (3, 10, 1, 199.99),
    (3, 5, 1, 89.99),
    (4, 1, 1, 79.99),
    (5, 10, 1, 199.99),
    (6, 3, 1, 59.99),
    (6, 1, 1, 79.99),
    (7, 4, 1, 129.99),
    (7, 10, 1, 199.99),
    (8, 5, 1, 89.99);
