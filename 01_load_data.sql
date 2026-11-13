USE bank_project;

-- Edit the two file paths below to match where the CSVs are on your computer.
-- Windows example: 'C:/Users/YourName/Downloads/bank_data.csv'
-- Mac example: '/Users/YourName/Downloads/bank_data.csv'

-- Loan data
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Downloads/bank_data.csv'
INTO TABLE bank_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Debit & Credit data
LOAD DATA LOCAL INFILE 'C:/Users/YourName/Downloads/credit_debit_data.csv'
INTO TABLE credit_debit_data
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Check it worked
SELECT COUNT(*) FROM bank_data;           -- should return 65535
SELECT COUNT(*) FROM credit_debit_data;   -- should return 100000
