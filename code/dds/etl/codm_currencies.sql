create or replace view currencies_snp as
select 
	k_p.currency_rk as currency_rk,
	s.currency as currency,
	report_date
from (select currency, report_date
      from stg_loans
      group by currency,report_date) s
left join k_currencies k_p
  on s.currency = k_p.currency
;

-- creating changes table
drop table if exists currencies_changes;
create table currencies_changes
as
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    currency_rk, currency
from codm_currencies d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date < d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    currency_rk, currency
from currencies_snp
;

insert into currencies_changes
select 'NEW' CHANGE_TYPE,    report_date, CAST(NULL AS TIMESTAMP) VALID_TO_DTTM,
    currency_rk, currency
from currencies_snp
except
select 'NEW' CHANGE_TYPE, sn.report_date, NULL VALID_TO_DTTM,
    currency_rk, currency
from codm_currencies d
  join stg_report_date sn
      on sn.report_date >= d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
;

insert into currencies_changes
select 'OLD' CHANGE_TYPE, sn.report_date, VALID_TO_DTTM,
    currency_rk, currency
from codm_currencies d
  join stg_report_date sn
      on sn.report_date >=  d.VALID_FROM_DTTM and sn.report_date <  d.VALID_TO_DTTM
except
select 'OLD' CHANGE_TYPE, report_date, TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    currency_rk, currency
from currencies_snp
;

-- check that we dont change closed period
select 1/ case when count(*)=0 then 1 else 0 end check_closed_periods from currencies_changes
where CHANGE_TYPE = 'OLD' and VALID_TO_DTTM <> TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS')
;

UPDATE codm_currencies
SET VALID_TO_DTTM = currencies_changes.report_date
FROM  currencies_changes
WHERE currencies_changes.CHANGE_TYPE = 'OLD' and codm_currencies.currency_rk = currencies_changes.currency_rk
    and currencies_changes.report_date >= codm_currencies.VALID_FROM_DTTM
    and currencies_changes.report_date <  codm_currencies.VALID_TO_DTTM
;

insert into codm_currencies (currency_rk, currency,
VALID_FROM_DTTM,VALID_TO_DTTM,PROCESSED_DTTM)
select currency_rk, currency,
    report_date VALID_FROM_DTTM,
    TO_DATE ('3999-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS') VALID_TO_DTTM,
    current_timestamp as PROCESSED_DTTM
from currencies_changes
where CHANGE_TYPE = 'NEW'
;
