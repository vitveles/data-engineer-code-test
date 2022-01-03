drop table if exists d_currencies;

create table d_currencies
as
select currency_rk, currency
from codm_currencies cur
where (select report_date from stg_report_date) between cur.valid_from_dttm and cur.valid_to_dttm
;
