drop table if exists d_calendar;

create table d_calendar
as
select
  date::date,
  extract('isodow' from date) as dow,
  to_char(date, 'dy') as day,
  extract('isoyear' from date) as "year",
  extract('week' from date) as week,
  extract('month' from date) as month,
  extract('day' from
          (date + interval '2 month - 1 day')
         ) as feb
from generate_series((select min(cast(effective_date as date)) from codm_loans as d),
                     (select report_date from stg_report_date),
                     interval '1 day') as t(date);