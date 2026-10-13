# 🚀 Credit Card Fraud Detection: ETL Pipeline & Anomaly Engine

![MySQL](https://img.shields.io/badge/MySQL-005C84?style=for-the-badge&logo=mysql&logoColor=white)
![Data Engineering](https://img.shields.io/badge/Data_Engineering-FF6F00?style=for-the-badge&logo=data-science&logoColor=white)
![Statistical Analysis](https://img.shields.io/badge/Statistical_Analysis-4CAF50?style=for-the-badge)

## 📌 Project Overview
This project transforms a flat, unstructured 1.2-million-row synthetic dataset into a highly optimized relational database (Star Schema). It features a resilient ETL pipeline built to bypass local hardware limits and culminates in a real-time Fraud Anomaly Detection Engine using advanced statistical SQL.

## 🏗️ Architecture & Data Modeling
I transformed the raw flat file into a normalized relational model to eliminate data redundancy and ensure data integrity.

*Insert Schema ERD Image Here: `![Database Schema](assets/schema_erd.png)`*

## ⚡ Key Engineering Achievements

### 1. Optimizing ETL for Mass Ingestion
Attempting to map and `JOIN` 1.2 million unindexed rows initially caused memory bottlenecks and server timeout crashes (12+ minute execution). 
* **The Fix:** Engineered a batched data pipeline (`LIMIT`/`OFFSET`) and implemented **Composite Indexing**.
* **The Result:** Query execution time dropped by **99%** (from server failure to 3.6 seconds per 200,000 rows).

### 2. Enforcing Data Integrity
The dataset contained massive overlapping merchant data (e.g., "Uber" in 50 different cities), which initially caused 199,000+ Duplicate Primary Key errors.
* **The Fix:** Rewrote the ingestion logic to utilize a strict 3-part relational `JOIN` (`merchant_name`, `category`, `city`), flawlessly importing 1M+ unique transactions.

## 🕵️‍♂️ The Fraud Detection Engine
Instead of using static rules to catch fraud, I built a statistical engine that calculates rolling historical baselines for *every individual user*.

Using **CTEs** and **Window Functions** (`AVG() OVER`, `STDDEV() OVER`), the engine establishes a user's normal spending habits. It then applies the **Three-Sigma Rule of Statistics** to automatically flag new transactions that spike 3 standard deviations above their personal norm.

```sql
-- Snippet of the Anomaly Logic
CASE 
    WHEN previous_transaction_count >= 5 
         AND amount > (historic_avg_spend + (3 * IFNULL(historic_std_dev, 0))) 
    THEN 'SUSPICIOUS - High Value Anomaly'
    ELSE 'NORMAL'
END AS fraud_flag
