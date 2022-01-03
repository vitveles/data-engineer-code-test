insert into k_currencies
select row_number() over(order by s.currency) as currency_rk, s.currency
from (
    select currency from stg_loans
    group by currency
    ) s
left join k_currencies k
  on k.currency = s.currency
where currency_rk is null
;