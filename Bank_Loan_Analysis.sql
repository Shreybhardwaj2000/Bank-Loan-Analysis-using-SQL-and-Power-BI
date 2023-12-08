select *
from bank_loan_data

# Key Performance indicator (KPI) requirements;

#1. Total loan applications 
;
SELECT count(id) as Total_Loan_Applications
FROM bank_loan_data;

SHOW VARIABLES LIKE 'sql_mode';
set global sql_mode='';
SET SQL_SAFE_UPDATES = 0;

# 2. MTD Loan Applications
# For this first I need to change column data type from 'text' to 'date' ''
;
UPDATE bank_loan_data
SET issue_date = STR_TO_DATE(issue_date, '%d-%m-%Y');

alter table bank_loan_data
modify column issue_date DATE ;

SELECT count(id) as MTD_Total_Loan_Apllication
FROM bank_loan_data
where MONTH(issue_date) = 12;

#3. PMTD(Previous month to date) Loan Applications

SELECT count(id) as PMTD_Total_Loan_Apllication
FROM bank_loan_data
where MONTH(issue_date) = 11;

#4. Total Funded amount
SELECT SUM(loan_amount) AS Total_Funded_Amount
FROM bank_loan_data;

#5.  MTD Total Funded amount
SELECT SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

#6.  PMTD Total Funded amount
SELECT SUM(loan_amount) AS PMTD_Total_Funded_Amount
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

#7. Total Amount received 
SELECT SUM(total_payment) AS Total_Amount_Received
FROM bank_loan_data;

#8. MTD Total Amount received 
SELECT SUM(total_payment) AS MTD_Total_Amount_Received
FROM bank_loan_data
WHERE MONTH(issue_date) = 12;

#9. PMTD Total Amount received 
SELECT SUM(total_payment) AS PMTD_Total_Amount_Received
FROM bank_loan_data
WHERE MONTH(issue_date) = 11;

#10. Average Interest Rate
# AS in first table there is some issue in importing the rates column data, so i imported the new table which only contains rates

SELECT ROUND(avg(int_rate), 5) * 100 AS Average_Interest_Rate
FROM bank_rates_dti;

#11. Average Interest Rate month on month basis

SELECT 
    YEAR(bank_loan_data.issue_date) AS year,
    MONTH(bank_loan_data.issue_date) AS month,
    ROUND(AVG(bank_rates_dti.int_rate), 4) * 100 AS avg_interest_rate
FROM 
    bank_loan_data
LEFT JOIN 
    bank_rates_dti ON bank_loan_data.id = bank_rates_dti.id
GROUP BY 
    YEAR(bank_loan_data.issue_date), MONTH(bank_loan_data.issue_date)
ORDER BY 
    YEAR(bank_loan_data.issue_date), MONTH(bank_loan_data.issue_date);


#12. Average dti(debt-to-equity ratio)

SELECT ROUND(avg(dti), 4) * 100 AS Average_dti
FROM bank_rates_dti;

#13. Average dti month on month basis

SELECT 
    YEAR(bank_loan_data.issue_date) AS year,
    MONTH(bank_loan_data.issue_date) AS month,
    ROUND(AVG(bank_rates_dti.dti), 4) * 100 AS avg_dti
FROM 
    bank_loan_data
LEFT JOIN 
    bank_rates_dti ON bank_loan_data.id = bank_rates_dti.id
GROUP BY 
    YEAR(bank_loan_data.issue_date), MONTH(bank_loan_data.issue_date)
ORDER BY 
    YEAR(bank_loan_data.issue_date), MONTH(bank_loan_data.issue_date);

#14. Good loan vs bad loan
# A. For good loan Percentage
 select (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100)
 /
 COUNT(id) AS Good_Loan_Percentage
 from bank_loan_data;
 
 # B. For good loan applications
 Select count(id) AS Good_loan_Applications
 From bank_loan_data
 where loan_status = 'Fully Paid' or loan_status = 'Current';
 
 # C. For Good loan funded amount
 Select SUM(loan_amount) AS Good_loan_Funded_Amount
 From bank_loan_data
 where loan_status = 'Fully Paid' or loan_status = 'Current';
 
 # D. For Good loan Received Amount
 Select SUM(total_payment) AS Good_loan_Received_Amount
 From bank_loan_data
 where loan_status = 'Fully Paid' or loan_status = 'Current';
 
 
 #15. Bad loan
# A. For Bad loan Percentage
 select (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100)
 /
 COUNT(id) AS Bad_Loan_Percentage
 from bank_loan_data;
 
 # B. For Bad loan applications
 Select count(id) AS Bad_loan_Applications
 From bank_loan_data
 where loan_status = 'Charged Off';
 
 # C. For Bad loan funded amount
 Select SUM(loan_amount) AS Bad_loan_Funded_Amount
 From bank_loan_data
 where loan_status = 'Charged Off';
 
 # D. For bad loan Received Amount
 Select SUM(total_payment) AS Bad_loan_Received_Amount
 From bank_loan_data
 where loan_status = 'Charged Off';
 

# 16. Loan Status Table View

SELECT bank_loan_data.loan_status,
COUNT(bank_loan_data.id) AS Total_Loan_Applications,
SUM(bank_loan_data.total_payment) AS Total_Payment_Received,
SUM(bank_loan_data.loan_amount) AS Total_Loan_Amount,
ROUND(AVG(bank_rates_dti.int_rate), 4) * 100 AS avg_interest_rate,
ROUND(AVG(bank_rates_dti.dti), 4) * 100 AS avg_dti
From bank_loan_data
LEFT JOIN 
    bank_rates_dti ON bank_loan_data.id = bank_rates_dti.id
Group by bank_loan_data.loan_status;


Select loan_status,
SUM(total_payment) AS MTD_Total_Amount_Received,
SUM(loan_amount) AS MTD_Total_Loan_Funded_Amount
From bank_loan_data
WHERE MONTH(issue_date) = 12
GROUP BY loan_status;


# 17. CHARTS
#A. Monthly trends by issue dates

SELECT 
MONTH(issue_date) AS Mounth_Number,
MONTHNAME(issue_date) AS Month_Name,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount

From bank_loan_data
Group by MONTH(issue_date),MONTHNAME(issue_date)
Order by Month(issue_date);

#B. Regional analysis by states

SELECT 
address_state,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount
From bank_loan_data
Group by address_state
Order by address_state;

#C. loan term analysis

SELECT 
term,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount
From bank_loan_data
Group by term
Order by term;

#D.Employee lenght analysis

SELECT 
emp_length,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount
From bank_loan_data
Group by emp_length
Order by emp_length;

#E.Loan purpose breakdown

SELECT 
purpose,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount
From bank_loan_data
Group by purpose
Order by COUNT(id) DESC;

#F.Home ownership analysis

SELECT 
home_ownership,
COUNT(id) AS Total_Loan_Application,
SUM(loan_amount) AS Total_Funded_Amount,
SUM(total_payment) AS Total_Received_Amount
From bank_loan_data
Group by home_ownership
Order by COUNT(id) DESC;









