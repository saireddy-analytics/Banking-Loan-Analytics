USE bank_project;

-- ===================================================================
-- PART A: BANK LOAN ANALYTICS  (table: bank_data)
-- ===================================================================

-- 1. KPI Metrics (sheet: KPI Metrics)
SELECT
    SUM(funded_amount) AS total_funded_loan,
    COUNT(account_id) AS total_loans,
    SUM(loan_amount) AS total_approved_loan,
    SUM(total_collection) AS total_collection,
    SUM(total_rrec_int) AS total_rrec_int,
    SUM(total_revenue) AS total_revenue
FROM bank_data;


-- 2. Loan Status Wise (sheet: Loan Status Wise)
SELECT
    CASE
        WHEN loan_status IN ('Active Loan', 'Transferred') THEN 'Active'
        WHEN loan_status IN ('Fully Paid', 'Paid Off', 'Cancelled', 'Insurance Paid Off', 'Net-Off') THEN 'Closed'
        WHEN loan_status IN ('NPA', 'Write Off') THEN 'Delinquent'
    END AS loan_status_group,
    SUM(funded_amount) AS total_funded_amount
FROM bank_data
GROUP BY loan_status_group
ORDER BY total_funded_amount DESC;


-- 3. Age Group Wise % (sheet: Loan Status Wise)
SELECT
    age_group,
    COUNT(account_id) AS loan_count,
    ROUND(100.0 * COUNT(account_id) / SUM(COUNT(account_id)) OVER (), 2) AS pct_of_loans
FROM bank_data
GROUP BY age_group
ORDER BY age_group;


-- 4. Verification Status Wise % (sheet: Loan Status Wise)
SELECT
    verification_status,
    COUNT(account_id) AS loan_count,
    ROUND(100.0 * COUNT(account_id) / SUM(COUNT(account_id)) OVER (), 2) AS pct_of_loans
FROM bank_data
GROUP BY verification_status
ORDER BY loan_count DESC;


-- 5. Default Loan Rate (sheet: Default & Delinquent)
SELECT
    SUM(CASE WHEN is_default_loan = 'Y' THEN 1 ELSE 0 END) AS default_loan,
    ROUND(100.0 * SUM(CASE WHEN is_default_loan = 'Y' THEN 1 ELSE 0 END) / COUNT(account_id), 2) AS default_loan_rate_pct
FROM bank_data;


-- 6. Delinquent Loan Rate (sheet: Default & Delinquent)
SELECT
    SUM(CASE WHEN is_delinquent_loan = 'Y' THEN 1 ELSE 0 END) AS delinquent_loan,
    COUNT(DISTINCT CASE WHEN is_delinquent_loan = 'Y' THEN client_id END) AS delinquent_client_count,
    ROUND(100.0 * SUM(CASE WHEN is_delinquent_loan = 'Y' THEN 1 ELSE 0 END) / COUNT(account_id), 2) AS delinquent_loan_rate_pct
FROM bank_data;


-- 7. Religion Wise % (sheet: Religion-Wise Loan)
SELECT
    religion,
    COUNT(account_id) AS loan_count,
    ROUND(100.0 * COUNT(account_id) / SUM(COUNT(account_id)) OVER (), 2) AS pct_of_loans
FROM bank_data
GROUP BY religion
ORDER BY loan_count DESC;


-- 8. Grade Wise (sheet: Grade Wise Loan)
SELECT
    grade,
    COUNT(account_id) AS loan_count
FROM bank_data
GROUP BY grade
ORDER BY grade;


-- 9. Branch Wise Performance - top 10 (sheet: Branch Wise Performance)
SELECT
    branch_name,
    SUM(total_revenue) AS total_revenue,
    SUM(funded_amount) AS funded_amount,
    SUM(total_collection) AS total_collection
FROM bank_data
GROUP BY branch_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 10. State Wise Performance (sheet: State Wise Performance)
SELECT
    state_name,
    SUM(total_revenue) AS total_revenue,
    SUM(funded_amount) AS funded_amount,
    SUM(total_collection) AS total_collection
FROM bank_data
GROUP BY state_name
ORDER BY state_name;


-- 11. Product Group Wise (sheet: Product Group Wise Loan)
SELECT
    purpose_category AS product_group,
    SUM(funded_amount) AS total_funded_amount
FROM bank_data
GROUP BY purpose_category
ORDER BY total_funded_amount DESC;


-- 12. Disbursement Trend by Year (sheet: Disbursemnet Trend)
SELECT
    disbursement_date_fy_years AS disbursement_fy,
    SUM(funded_amount) AS total_funded_amount
FROM bank_data
GROUP BY disbursement_date_fy_years
ORDER BY disbursement_fy;


-- ===================================================================
-- PART B: BANK DEBIT & CREDIT ANALYTICS  (table: credit_debit_data, 100,000 rows)
-- Data covers 01-Jan-2024 to 01-Dec-2024. December has only 1 day of data
-- (305 transactions), so treat December as a partial month in trends.
-- ===================================================================


-- 1. Total Credit Amount
SELECT
    SUM(amount) AS total_credit_amount
FROM credit_debit_data
WHERE transaction_type = 'Credit';


-- 2. Total Debit Amount
SELECT
    SUM(amount) AS total_debit_amount
FROM credit_debit_data
WHERE transaction_type = 'Debit';


-- 3 & 4. Credit to Debit Ratio + Net Transaction Amount (KPI card summary)
SELECT
    COUNT(*) AS total_transactions,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) AS total_credit_amount,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END) AS total_debit_amount,
    ROUND(SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END)
        / SUM(CASE WHEN transaction_type = 'Debit' THEN amount ELSE 0 END), 4) AS credit_to_debit_ratio,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE -amount END) AS net_transaction_amount
FROM credit_debit_data;


-- 5. Account Activity Ratio  (Number of transactions / Account balance)
-- 5a. Per account - top 10 most active relative to balance
SELECT
    account_number,
    customer_name,
    COUNT(*) AS no_of_transactions,
    MAX(balance) AS account_balance,
    ROUND(COUNT(*) / MAX(balance), 6) AS account_activity_ratio
FROM credit_debit_data
GROUP BY account_number, customer_name
ORDER BY account_activity_ratio DESC
LIMIT 10;

-- 5b. Overall average activity ratio (for the KPI card)
SELECT
    ROUND(AVG(account_activity_ratio), 6) AS avg_account_activity_ratio
FROM (
    SELECT account_number, COUNT(*) / MAX(balance) AS account_activity_ratio
    FROM credit_debit_data
    GROUP BY account_number
) t;


-- 6. Transactions per Day / Week / Month
-- 6a. Per month
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_amount
FROM credit_debit_data
GROUP BY txn_month
ORDER BY txn_month;

-- 6b. Per week
SELECT
    YEARWEEK(transaction_date, 1) AS txn_year_week,
    MIN(transaction_date) AS week_start,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_amount
FROM credit_debit_data
GROUP BY txn_year_week
ORDER BY txn_year_week;

-- 6c. Per day
SELECT
    transaction_date,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_amount
FROM credit_debit_data
GROUP BY transaction_date
ORDER BY transaction_date;

-- 6d. Average transactions per day / week / month (KPI card)
SELECT
    ROUND(COUNT(*) / COUNT(DISTINCT transaction_date), 2) AS avg_txn_per_day,
    ROUND(COUNT(*) / COUNT(DISTINCT YEARWEEK(transaction_date, 1)), 2) AS avg_txn_per_week,
    ROUND(COUNT(*) / COUNT(DISTINCT DATE_FORMAT(transaction_date, '%Y-%m')), 2) AS avg_txn_per_month
FROM credit_debit_data;


-- 7. Total Transaction Amount by Branch
SELECT
    branch,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_transaction_amount,
    SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END) AS credit_amount,
    SUM(CASE WHEN transaction_type = 'Debit'  THEN amount ELSE 0 END) AS debit_amount
FROM credit_debit_data
GROUP BY branch
ORDER BY total_transaction_amount DESC;


-- 8. Transaction Volume by Bank
SELECT
    bank_name,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_transaction_amount,
    ROUND(100.0 * SUM(amount) / SUM(SUM(amount)) OVER (), 2) AS pct_of_total_amount
FROM credit_debit_data
GROUP BY bank_name
ORDER BY total_transaction_amount DESC;


-- 9. Transaction Method Distribution
SELECT
    transaction_method,
    COUNT(*) AS no_of_transactions,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS pct_of_transactions,
    SUM(amount) AS total_amount
FROM credit_debit_data
GROUP BY transaction_method
ORDER BY no_of_transactions DESC;


-- 10. Branch Transaction Growth (month-over-month % change in amount)
SELECT
    branch,
    txn_month,
    total_amount,
    prev_month_amount,
    ROUND(100.0 * (total_amount - prev_month_amount) / prev_month_amount, 2) AS mom_growth_pct
FROM (
    SELECT
        branch,
        txn_month,
        total_amount,
        LAG(total_amount) OVER (PARTITION BY branch ORDER BY txn_month) AS prev_month_amount
    FROM (
        SELECT
            branch,
            DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
            SUM(amount) AS total_amount
        FROM credit_debit_data
        GROUP BY branch, DATE_FORMAT(transaction_date, '%Y-%m')
    ) m
) t
ORDER BY branch, txn_month;

-- 10b. Branch growth Jan -> Nov 2024 (last full month; December is partial)
SELECT
    branch,
    SUM(CASE WHEN DATE_FORMAT(transaction_date, '%Y-%m') = '2024-01' THEN amount ELSE 0 END) AS jan_amount,
    SUM(CASE WHEN DATE_FORMAT(transaction_date, '%Y-%m') = '2024-11' THEN amount ELSE 0 END) AS nov_amount,
    ROUND(100.0 *
        (SUM(CASE WHEN DATE_FORMAT(transaction_date, '%Y-%m') = '2024-11' THEN amount ELSE 0 END)
       - SUM(CASE WHEN DATE_FORMAT(transaction_date, '%Y-%m') = '2024-01' THEN amount ELSE 0 END))
       / SUM(CASE WHEN DATE_FORMAT(transaction_date, '%Y-%m') = '2024-01' THEN amount ELSE 0 END), 2) AS growth_pct_jan_to_nov
FROM credit_debit_data
GROUP BY branch
ORDER BY growth_pct_jan_to_nov DESC;


-- 11. High-Risk Transaction Flag
-- Rule: any transaction of Rs 4,500 or more is flagged High Risk.
-- Change the threshold below if your group agrees on a different limit.
SET @high_risk_threshold = 4500;

-- 11a. Flag count and share (KPI card)
SELECT
    SUM(CASE WHEN amount >= @high_risk_threshold THEN 1 ELSE 0 END) AS high_risk_transactions,
    ROUND(100.0 * SUM(CASE WHEN amount >= @high_risk_threshold THEN 1 ELSE 0 END) / COUNT(*), 2) AS high_risk_pct,
    SUM(CASE WHEN amount >= @high_risk_threshold THEN amount ELSE 0 END) AS high_risk_amount
FROM credit_debit_data;

-- 11b. Flag split by transaction type
SELECT
    transaction_type,
    CASE WHEN amount >= @high_risk_threshold THEN 'High Risk' ELSE 'Normal' END AS risk_flag,
    COUNT(*) AS no_of_transactions,
    SUM(amount) AS total_amount
FROM credit_debit_data
GROUP BY transaction_type, risk_flag
ORDER BY transaction_type, risk_flag;

-- 11c. Optional: a view with the flag on every row (useful for Power BI / Tableau)
CREATE OR REPLACE VIEW vw_credit_debit_flagged AS
SELECT
    c.*,
    CASE WHEN amount >= 4500 THEN 'High Risk' ELSE 'Normal' END AS risk_flag
FROM credit_debit_data c;


-- 12. Suspicious Transaction Frequency (count of flagged transactions over time)
-- 12a. By month
SELECT
    DATE_FORMAT(transaction_date, '%Y-%m') AS txn_month,
    COUNT(*) AS high_risk_transactions,
    SUM(amount) AS high_risk_amount
FROM credit_debit_data
WHERE amount >= @high_risk_threshold
GROUP BY txn_month
ORDER BY txn_month;

-- 12b. By branch and bank
SELECT
    branch,
    bank_name,
    COUNT(*) AS high_risk_transactions
FROM credit_debit_data
WHERE amount >= @high_risk_threshold
GROUP BY branch, bank_name
ORDER BY high_risk_transactions DESC;
