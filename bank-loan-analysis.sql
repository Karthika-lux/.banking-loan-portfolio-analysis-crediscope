create database banking_loan_analysis;
use banking_loan_analysis;
select * from banking_loan_analysis.applications_sql;
select * from banking_loan_analysis.loans_clean;


select count(*) as loans
from loans_clean;

select count(*) as loan_applications from applications_sql;


select loan_status,COUNT(*) as loan_count
from loans_clean
group by loan_status
order by loan_count desc;

-- Portfolio Health
select count(*) as total_loans,
sum(default_flag) as default_loans,
sum(case when days_past_due > 0 and default_flag = 0
then 1 else 0 end) as overdue_loans,
round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct,
round(100.0 * sum(case when days_past_due > 0 and default_flag = 0
then 1 else 0 end) / count(*), 2) as overdue_rate_pct
from loans_clean;

-- Default rate by loan type
select loan_type, count(*) total_loans ,
sum(default_flag) as default_loans,round(100.0 * sum(default_flag) / count(*), 2)
as default_rate_pct from loans_clean group by loan_type
order by default_rate_pct desc;


-- default rate by credit band
select credit_band,count(*) as total_loans,
sum(default_flag) as default_loans,round(
100.0 * sum(default_flag) / count(*), 2)
 as default_rate_pct from loans_clean
group by credit_band
order by default_rate_pct desc;


-- Approval Type
select employment_type,count(*) as total_applications,
sum(case when approval_status = 'Approved' then 1
else 0 end) as approved_applications,
round(100.0 * sum(case when approval_status = 'Approved' then 1
else 0 end) / count(*), 2) as approval_rate_pct
from applications_sql
group by employment_type
order by approval_rate_pct desc;

-- Rejection reason
select
    rejection_reason,
    count(*) as rejected_applications
from applications_sql
where approval_status = 'Rejected'
group by rejection_reason
order by rejected_applications desc;



-- Region wise rate 
select region,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct
from loans_clean
group by region
order by default_rate_pct desc;

-- income band
select income_band,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct
from loans_clean
group by income_band
order by default_rate_pct desc;

-- Loan Size 
select loan_size_band,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct
from loans_clean
group by loan_size_band
order by default_rate_pct desc;


-- Payment Status
select dpd_bucket,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(100.0 * count(*) / (select count(*) from loans_clean), 2) as portfolio_pct
from loans_clean
group by dpd_bucket
order by total_loans desc;

-- DPD category
select dpd_bucket,count(*) as total_loans,
round(sum(outstanding_balance), 2) as total_outstanding,
round(avg(days_past_due), 2) as avg_days_past_due
from loans_clean
group by dpd_bucket
order by total_outstanding desc;

-- Age group
select age_group,
count(*) as total_loans,
sum(default_flag) as default_loans,
round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct
from loans_clean
group by age_group
order by default_rate_pct desc;

-- Region and Loan Type
select region,loan_type,
count(*) as total_loans,
sum(default_flag) as default_loans,
round(100.0 * sum(default_flag) / count(*), 2) as default_rate_pct
from loans_clean
group by region, loan_type
order by default_rate_pct desc;

-- Approval loan type
select
l.loan_type,
    count(*) as total_applications,
    sum(case when a.approval_status = 'Approved' then 1
        else 0 end) as approved_applications,
    round(100.0 * sum(case when a.approval_status = 'Approved' then 1
	else 0 end) / count(*), 2) as approval_rate_pct
from applications_sql a join loans_clean l
on a.application_id = l.application_id
group by l.loan_type
order by approval_rate_pct desc;


-- Average interest rate by credit band
select
    credit_band,
    count(*) as total_loans,
    round(avg(credit_score), 2) as avg_credit_score,
    round(avg(interest_rate), 2) as avg_interest_rate
from loans_clean
group by credit_band
order by avg_interest_rate desc;

-- employee loan type
select
    employment_type,
    count(*) as total_loans,
    round(avg(loan_amount), 2) as avg_loan_amount,
    round(avg(annual_income), 2) as avg_annual_income,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct
from loans_clean
group by employment_type
order by default_rate_pct desc;


-- default trend
select
    disbursal_quarter,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct
from loans_clean
group by disbursal_quarter
order by disbursal_quarter;

-- Loan list
select
loan_id,customer_id,loan_type,credit_band,
days_past_due,loan_to_income,
outstanding_balance,default_flag
from loans_clean
where default_flag = 1
   or days_past_due > 30
   or credit_band = 'Poor'
order by
    default_flag desc,
    days_past_due desc,
    outstanding_balance desc
limit 50;

-- Approval and rejection
select
    approval_status,
    count(*) as total_applications,
    round(
        100.0 * count(*) /
        (select count(*) from applications_sql), 2
    ) as percentage
from applications_sql
group by approval_status
order by total_applications desc;


-- customer risk level
select
    customer_id,
    count(*) as total_loans,
    round(sum(loan_amount), 2) as total_loan_amount,
    sum(default_flag) as default_loans,
    round(sum(outstanding_balance), 2) as total_outstanding
from loans_clean
group by customer_id
having sum(default_flag) > 0
order by default_loans desc, total_outstanding desc
limit 50;


-- portfolio summary

create or replace view portfolio_summary as
select
    loan_type,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct,
    round(sum(loan_amount), 2) as total_loan_amount,
    round(sum(outstanding_balance), 2) as total_outstanding
from loans_clean
group by loan_type;

select * from portfolio_summary;


-- portfolio summary final
select
    count(*) as total_loans,
    round(sum(loan_amount), 2) as total_loan_amount,
    round(sum(outstanding_balance), 2) as total_outstanding,
    sum(default_flag) as default_loans,
    sum(case
        when days_past_due > 0
             and default_flag = 0
        then 1
        else 0
    end) as overdue_loans,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct,
    round(
        100.0 * sum(case
            when days_past_due > 0
                 and default_flag = 0
            then 1
            else 0
        end) / count(*), 2
    ) as overdue_rate_pct
from loans_clean;

-- top 10 interest 
select
    loan_type,
    count(*) as total_loans,
    round(sum(outstanding_balance), 2) as total_outstanding,
    round(avg(interest_rate), 2) as avg_interest_rate
from loans_clean
group by loan_type
order by total_outstanding desc
limit 10;

-- rank risk
select
    region,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct,
    rank() over (
        order by sum(default_flag) / count(*) desc
    ) as risk_rank
from loans_clean
group by region
order by risk_rank;

-- risk category
select
    case
        when default_flag = 1
             or days_past_due > 90
        then 'high risk'
        when days_past_due > 30
             or credit_band = 'Poor'
        then 'medium risk'
        else 'low risk'
    end as risk_category,
    count(*) as total_loans,
    sum(default_flag) as default_loans,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct
from loans_clean
group by risk_category
order by default_rate_pct desc;


-- total loans
select
    count(*) as total_loans,
    count(distinct loan_id) as unique_loan_ids,
    count(distinct application_id) as unique_application_ids,
    sum(case
        when loan_amount is null then 1
        else 0
    end) as missing_loan_amount,
    sum(case
        when default_flag not in (0, 1)
             or default_flag is null
        then 1
        else 0
    end) as invalid_default_flags
from loans_clean;

-- summary
select
    count(*) as total_loans,
    count(distinct customer_id) as total_customers,
    round(sum(loan_amount), 2) as total_loan_amount,
    round(sum(outstanding_balance), 2) as total_outstanding,
    sum(default_flag) as default_loans,
    round(avg(interest_rate), 2) as avg_interest_rate,
    round(
        100.0 * sum(default_flag) / count(*), 2
    ) as default_rate_pct
from loans_clean;