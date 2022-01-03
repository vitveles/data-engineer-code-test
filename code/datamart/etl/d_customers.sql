drop table if exists d_customers;

create table d_customers
as
select customer_rk,customer_number,name,city,dob
from codm_customers cur
where (select report_date from stg_report_date) between cur.valid_from_dttm and cur.valid_to_dttm
;
