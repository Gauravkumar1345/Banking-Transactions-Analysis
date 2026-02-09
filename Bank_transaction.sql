CREATE DATABASE IF NOT EXISTS banking_project;
USE banking_project;

-- Q1. Count total number of transactions in the dataset.
SELECT COUNT(*) AS total_transactions
FROM bank_transactions;

-- Q2. Find the number of unique customers.
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM bank_transactions;

-- Q3. Display first 10 records.
SELECT *
FROM bank_transactions
LIMIT 10;

-- Q4. Show count of Debit vs Credit transactions.
SELECT txn_type, COUNT(*) AS txn_count
FROM bank_transactions
GROUP BY txn_type;

-- Q5. Calculate total transaction amount by type (Debit/Credit).
SELECT txn_type, SUM(txn_amount) AS total_amount
FROM bank_transactions
GROUP BY txn_type;

-- Q6. Find average transaction amount for each transaction channel.
SELECT txn_channel, AVG(txn_amount) AS avg_amount
FROM bank_transactions
GROUP BY txn_channel;

-- Q7. Identify top 5 merchant categories by debit spending.
SELECT merchant_category, SUM(txn_amount) AS total_debit_spend
FROM bank_transactions
WHERE txn_type = 'Debit'
GROUP BY merchant_category
ORDER BY total_debit_spend DESC
LIMIT 5;

-- Q8. Find top 10 customers by total debit spending.
SELECT customer_id, SUM(txn_amount) AS total_debit_spend
FROM bank_transactions
WHERE txn_type='Debit'
GROUP BY customer_id
ORDER BY total_debit_spend DESC
LIMIT 10;

-- Q9. Calculate transaction count, total spend, and average transaction amount per customer.
SELECT 
  customer_id,
  COUNT(*) AS txn_count,
  SUM(CASE WHEN txn_type='Debit' THEN txn_amount ELSE 0 END) AS total_debit_spend,
  AVG(txn_amount) AS avg_txn_amount
FROM bank_transactions
GROUP BY customer_id;

-- Q10. List all inactive customers.
SELECT DISTINCT customer_id
FROM bank_transactions
WHERE account_active = 0;

-- Q11. Show monthly transaction count and total amount.
SELECT 
  DATE_FORMAT(txn_date, '%Y-%m') AS month,
  COUNT(*) AS txn_count,
  SUM(txn_amount) AS total_amount
FROM bank_transactions
GROUP BY month;

-- Q12. Compare weekend vs weekday spending.
SELECT 
  is_weekend,
  COUNT(*) AS txn_count,
  SUM(txn_amount) AS total_amount
FROM bank_transactions
GROUP BY is_weekend;

-- Q13. Find customers with credit score below 600.
SELECT DISTINCT customer_id
FROM bank_transactions
WHERE credit_score < 600;

-- Q14. Identify transactions above 15,000 (high value).
SELECT customer_id, txn_date, txn_amount
FROM bank_transactions
WHERE txn_amount >= 15000
ORDER BY txn_amount DESC;

-- Q15. Show spending by city.
SELECT city, SUM(txn_amount) AS total_spend
FROM bank_transactions
GROUP BY city;

-- Q16. Show spending by employment type.
SELECT employment_type, SUM(txn_amount) AS total_spend
FROM bank_transactions
GROUP BY employment_type;

-- Q17. Calculate average credit score per city.
SELECT city, AVG(credit_score) AS avg_credit_score
FROM bank_transactions
GROUP BY city;

-- Q18. Rank customers by total debit spending.
WITH cte AS (
  SELECT customer_id,
         SUM(CASE WHEN txn_type='Debit' THEN txn_amount ELSE 0 END) AS total_debit_spend
  FROM bank_transactions
  GROUP BY customer_id
)
SELECT customer_id, total_debit_spend,
       DENSE_RANK() OVER (ORDER BY total_debit_spend DESC) AS spend_rank
FROM cte;

-- Q19. Calculate running debit total for each customer over time.
SELECT customer_id, txn_date, txn_amount,
       SUM(CASE WHEN txn_type='Debit' THEN txn_amount ELSE 0 END)
       OVER (PARTITION BY customer_id ORDER BY txn_date) AS running_debit_total
FROM bank_transactions;

-- Q20. Find customers spending more than 50% of their income.
SELECT 
  customer_id,
  MAX(annual_income) AS annual_income,
  SUM(CASE WHEN txn_type='Debit' THEN txn_amount ELSE 0 END) AS total_spend,
  SUM(CASE WHEN txn_type='Debit' THEN txn_amount ELSE 0 END)/MAX(annual_income) AS spend_income_ratio
FROM bank_transactions
GROUP BY customer_id
HAVING spend_income_ratio > 0.5;