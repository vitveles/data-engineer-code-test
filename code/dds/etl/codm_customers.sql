create or replace view customers_snp as
select
	k_p.customer_rk as customer_rk,
	s.customer_number,
	s.name,
	s.city,
	s.dob,
	report_date
from stg_customers s
left join k_customers k_p
  on s.customer_number = k_p.customer_number
;

-- creating changes table
drop table if exists customers_changes;
create table customers_changes
as
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from codm_customers d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date < d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from customers_snp
;

insert into customers_changes
select 'NEW' CHANGE_TYPE,    report_date, CAST(NULL AS TIMESTAMP) VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from customers_snp
except
select 'NEW' CHANGE_TYPE, sn.report_date, NULL VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from codm_customers d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
;

insert into customers_changes
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from codm_customers d
  join stg_report_date sn
      on sn.report_date >=  d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    customer_rk, customer_number, name, city, dob
from customers_snp
;

-- check that we dont change closed period
select 1/ case when count(*)=0 then 1 else 0 end check_closed_periods from customers_changes
where CHANGE_TYPE = 'OLD' and VALID_TO_DTTM <> TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
;

UPDATE codm_customers
SET VALID_TO_DTTM = customers_changes.report_date
FROM  customers_changes
WHERE customers_changes.CHANGE_TYPE = 'OLD' and codm_customers.customer_rk = customers_changes.customer_rk
    and customers_changes.report_date >= codm_customers.VALID_FROM_DTTM
    and customers_changes.report_date <  codm_customers.VALID_TO_DTTM
;

insert into codm_customers (customer_rk, customer_number, name, city, dob,
VALID_FROM_DTTM,VALID_TO_DTTM,PROCESSED_DTTM)
select customer_rk, customer_number, name, city, dob,
    report_date VALID_FROM_DTTM,
    TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    current_timestamp as PROCESSED_DTTM
from customers_changes
where CHANGE_TYPE = 'NEW'
;
