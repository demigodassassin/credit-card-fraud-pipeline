-- ==============================================================================
-- 1. PERFORMANCE OPTIMIZATION
-- Create a composite index to make the 3-part string JOIN lightning fast.
-- Without this, the 1.2M row insertion takes 12+ minutes and crashes the server.
-- With this, batches process in ~3 seconds.
-- ==============================================================================

CREATE INDEX idx_merch_composite ON merchants(merchant_name, merchant_category, location_city);

-- ==============================================================================
-- 2. BATCHED DATA INGESTION (ETL)
-- Moving data from staging_fraud to the normalized transactions table.
-- Processed in chunks of 200,000 using LIMIT and OFFSET to prevent memory timeouts.
-- INSERT IGNORE is used to handle and skip dirty duplicate records gracefully.
-- ==============================================================================

-- Batch 1: Rows 1 to 200,000
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 200000 OFFSET 0;

-- Batch 2: Rows 200,001 to 400,000
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 200000 OFFSET 200000;

-- Batch 3: Rows 400,001 to 600,000
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 200000 OFFSET 400000;

-- Batch 4: Rows 600,001 to 800,000
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 200000 OFFSET 600000;

-- Batch 5: Rows 800,001 to 1,000,000
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 200000 OFFSET 800000;

-- Batch 6: Rows 1,000,001 to End
INSERT IGNORE INTO transactions (transaction_id, user_id, merchant_id, amount, transaction_timestamp)
SELECT 
    s.trans_num, 
    CAST(s.cc_num AS UNSIGNED), 
    m.merchant_id, 
    CAST(s.amt AS DECIMAL(10,2)), 
    CAST(STR_TO_DATE(s.trans_date_trans_time, '%Y-%m-%d %H:%i:%s') AS DATETIME)
FROM staging_fraud s
JOIN merchants m 
  ON s.merchant = m.merchant_name 
  AND s.category = m.merchant_category 
  AND s.city = m.location_city
LIMIT 400000 OFFSET 1000000;