-- ==============================================================================
-- 1. ANALYTICAL PERFORMANCE OPTIMIZATION
-- Create an index specifically for the Window Functions to prevent MySQL from 
-- performing a massive, memory-heavy filesort on the timestamps.
-- ==============================================================================

CREATE INDEX idx_window_sort ON transactions(user_id, transaction_timestamp);

-- ==============================================================================
-- 2. STATISTICAL FRAUD ANOMALY ENGINE (The 3-Sigma Rule)
-- Uses Common Table Expressions (CTEs) and Window Functions to calculate a 
-- rolling baseline of normal spending behavior per user.
-- Flags transactions that spike 3 standard deviations above their personal average.
-- 
-- Note: A targeted subquery (TargetUsers) is used to sample accounts and prevent 
-- local hardware memory crashes common with OLAP tasks on unclustered databases.
-- ==============================================================================

WITH TargetUsers AS (
    -- Sample a subset of users to process instantly without local hardware timeouts
    SELECT user_id FROM users LIMIT 10
),
UserSpendingBaselines AS (
    SELECT 
        t.transaction_id,
        t.user_id,
        t.merchant_id,
        t.amount,
        t.transaction_timestamp,
        
        -- Calculate the rolling historical average spend for this specific user
        AVG(t.amount) OVER(
            PARTITION BY t.user_id 
            ORDER BY t.transaction_timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS historic_avg_spend,
        
        -- Calculate the user's spending variance (Standard Deviation)
        STDDEV(t.amount) OVER(
            PARTITION BY t.user_id 
            ORDER BY t.transaction_timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS historic_std_dev,
        
        -- Count prior transactions to ensure statistical reliability
        COUNT(t.transaction_id) OVER(
            PARTITION BY t.user_id 
            ORDER BY t.transaction_timestamp 
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_transaction_count
        
    FROM transactions t
    -- ONLY process the math for our targeted accounts
    WHERE t.user_id IN (SELECT user_id FROM TargetUsers)
)

SELECT 
    u.transaction_id,
    u.user_id,
    m.merchant_name,
    m.merchant_category,
    u.amount AS transaction_amount,
    ROUND(u.historic_avg_spend, 2) AS user_typical_spend,
    
    -- Business Logic: Flag as SUSPICIOUS if the current amount breaks the 3-Sigma threshold
    -- Requires a minimum of 5 previous transactions to establish a valid baseline
    CASE 
        WHEN u.previous_transaction_count >= 5 
             AND u.amount > (u.historic_avg_spend + (3 * IFNULL(u.historic_std_dev, 0))) 
        THEN 'SUSPICIOUS - High Value Anomaly'
        ELSE 'NORMAL'
    END AS fraud_flag

FROM UserSpendingBaselines u
JOIN merchants m ON u.merchant_id = m.merchant_id

-- Filter the final output to only show transactions that triggered the anomaly flag
WHERE 
    u.previous_transaction_count >= 5 
    AND u.amount > (u.historic_avg_spend + (3 * IFNULL(u.historic_std_dev, 0)))
ORDER BY u.amount DESC;