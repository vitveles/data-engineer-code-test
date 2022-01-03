drop table if exists f_client_loans;

create table f_client_loans as
select d_calendar.date as report_date, customer_rk, currency_rk, sum(amount) as amount
from codm_loans loans
  join d_calendar on d_calendar.date >= cast(loans.effective_date as date)
    and d_calendar.date - cast(loans.effective_date as date) >= loans.term
where (select report_date from stg_report_date) between loans.valid_from_dttm and loans.valid_to_dttm
group by 1,2,3
;