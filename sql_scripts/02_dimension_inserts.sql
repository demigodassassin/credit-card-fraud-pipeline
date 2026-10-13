-- =============================================================================================
-- Importing the data 

INSERT IGNORE INTO users (user_id, first_name, last_name, email, country)
SELECT DISTINCT 
    CAST(cc_num AS UNSIGNED), 
    first_name, 
    last_name, 
    CONCAT(first_name, last_name, RIGHT(cc_num, 4), '@example.com'), 
    'US'
FROM staging_fraud;
------------------------------------------------------------------------------------------------
INSERT IGNORE INTO merchants (merchant_name, merchant_category, location_city)
SELECT DISTINCT 
    merchant, 
    category, 
    city
FROM staging_fraud;
------------------------------------------------------------------------------------------------
