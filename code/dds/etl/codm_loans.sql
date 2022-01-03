create or replace view loans_snp as
select 
	k_p.loan_rk as loan_rk,
	s.loan_number,
    k_p1.customer_rk,
    CAST(s.amount AS NUMERIC(10,4)) AS amount,
    CAST(s.term AS NUMERIC(4)) AS term,
    CAST(s.interest_rate AS NUMERIC(10,4)) AS interest_rate,
    CAST(s.period_cost AS NUMERIC(10,4)) AS period_cost,
    k_p2.currency_rk,
    s.grade,
    s.effective_date,
	report_date
from stg_loans s
left join k_loans k_p
  on s.loan_number = k_p.loan_number
left join k_customers k_p1
  on s.customer_number = k_p1.customer_number
left join k_currencies k_p2
  on s.currency = k_p2.currency
;

-- creating changes table
drop table if exists loans_changes;
create table loans_changes
as
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from codm_loans d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date < d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from loans_snp
;

insert into loans_changes
select 'NEW' CHANGE_TYPE,    report_date, CAST(NULL AS TIMESTAMP) VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from loans_snp
except
select 'NEW' CHANGE_TYPE, sn.report_date, NULL VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from codm_loans d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
;

insert into loans_changes
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from codm_loans d
  join stg_report_date sn
      on sn.report_date >=  d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date
from loans_snp
;

-- check that we dont change closed period
select 1/ case when count(*)=0 then 1 else 0 end check_closed_periods from loans_changes
where CHANGE_TYPE = 'OLD' and VALID_TO_DTTM <> TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
;

UPDATE codm_loans
SET VALID_TO_DTTM = loans_changes.report_date
FROM  loans_changes
WHERE loans_changes.CHANGE_TYPE = 'OLD' and codm_loans.loan_rk = loans_changes.loan_rk
    and loans_changes.report_date >= codm_loans.VALID_FROM_DTTM
    and loans_changes.report_date <  codm_loans.VALID_TO_DTTM
;

insert into codm_loans (loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date,
VALID_FROM_DTTM,VALID_TO_DTTM,PROCESSED_DTTM)
select loan_rk, loan_number, customer_rk, amount, term, interest_rate, period_cost, currency_rk, grade, effective_date,
    report_date VALID_FROM_DTTM,
    TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    current_timestamp as PROCESSED_DTTM
from loans_changes
where CHANGE_TYPE = 'NEW'
;
