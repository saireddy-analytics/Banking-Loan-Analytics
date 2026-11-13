-- STEP 1: Run this file once. It creates the database, BOTH tables, and loads BOTH CSVs.
-- CSVs are read directly from: C:/Users/adith/Downloads/Bank_Project_SQL/
-- STEP 2: Then run bank_analytics.sql

SET GLOBAL local_infile = 1;
CREATE DATABASE IF NOT EXISTS bank_project;
USE bank_project;

DROP TABLE IF EXISTS bank_data;

CREATE TABLE bank_data (
    state_abbr VARCHAR(10),
    account_id VARCHAR(30),
    age_group VARCHAR(20),
    bh_name VARCHAR(100),
    bank_name VARCHAR(100),
    branch_name VARCHAR(100),
    caste VARCHAR(50),
    center_id VARCHAR(30),
    city VARCHAR(100),
    client_id VARCHAR(30),
    client_name VARCHAR(100),
    close_client VARCHAR(10),
    closed_date VARCHAR(20),
    expected_close_date VARCHAR(20),
    actual_duration DECIMAL(10,2),
    credit_officer_name VARCHAR(100),
    date_of_birth VARCHAR(20),
    disbursed_by VARCHAR(100),
    disbursement_date VARCHAR(20),
    disbursement_date_fy_years DECIMAL(10,2),
    gender_id VARCHAR(20),
    home_ownership VARCHAR(30),
    loan_status VARCHAR(50),
    loan_status_2 VARCHAR(30),
    region_name VARCHAR(100),
    loan_transfer_date VARCHAR(20),
    next_meeting_date VARCHAR(20),
    product_code VARCHAR(20),
    grade VARCHAR(10),
    sub_grade VARCHAR(10),
    product_id VARCHAR(30),
    purpose_category VARCHAR(50),
    religion VARCHAR(30),
    verification_status VARCHAR(30),
    state_name VARCHAR(50),
    transfer_logic VARCHAR(20),
    is_delinquent_loan VARCHAR(5),
    is_default_loan VARCHAR(5),
    age DECIMAL(10,2),
    delinq_2_yrs DECIMAL(10,2),
    application_type VARCHAR(30),
    loan_amount DECIMAL(18,2),
    funded_amount DECIMAL(18,2),
    funded_amount_inv DECIMAL(18,2),
    term_in_month DECIMAL(10,2),
    int_rate DECIMAL(10,4),
    total_payment DECIMAL(18,2),
    total_pymnt_inv DECIMAL(18,2),
    total_recvd_principal DECIMAL(18,2),
    total_fees DECIMAL(18,4),
    total_rrec_int DECIMAL(18,2),
    total_rec_late_fee DECIMAL(18,4),
    recoveries DECIMAL(18,2),
    collection_recovery_fee DECIMAL(18,4),
    total_collection DECIMAL(18,2),
    total_revenue DECIMAL(18,2)
);

DROP TABLE IF EXISTS credit_debit_data;

CREATE TABLE credit_debit_data (
    customer_id VARCHAR(40),
    customer_name VARCHAR(100),
    account_number BIGINT,
    transaction_date DATE,
    transaction_type VARCHAR(10),
    amount DECIMAL(12,2),
    balance DECIMAL(12,2),
    description VARCHAR(100),
    branch VARCHAR(50),
    transaction_method VARCHAR(30),
    currency VARCHAR(5),
    bank_name VARCHAR(50)
);

-- Load loan data
LOAD DATA LOCAL INFILE 'C:/Users/adith/Downloads/Bank_Project_SQL/bank_data.csv'
INTO TABLE bank_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Load debit & credit data
LOAD DATA LOCAL INFILE 'C:/Users/adith/Downloads/Bank_Project_SQL/credit_debit_data.csv'
INTO TABLE credit_debit_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check it worked: should return 65535 and 100000
SELECT (SELECT COUNT(*) FROM bank_data) AS bank_data_rows,
       (SELECT COUNT(*) FROM credit_debit_data) AS credit_debit_rows;
