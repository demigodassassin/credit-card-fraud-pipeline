-- =================================================================
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(50)
);

CREATE TABLE merchants (
    merchant_id INT AUTO_INCREMENT PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_category VARCHAR(50) NOT NULL,
    location_city VARCHAR(50)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(255) PRIMARY KEY, 
    user_id BIGINT NOT NULL,
    merchant_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL, 
    transaction_timestamp DATETIME,
    status VARCHAR(20) DEFAULT 'COMPLETED',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (merchant_id) REFERENCES merchants(merchant_id) ON DELETE RESTRICT
);
-- =============================================================================================
