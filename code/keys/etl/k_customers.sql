insert into k_customers
select row_number() over(order by s.customer_number) as customer_rk, s.customer_number
from (
    select customer_number from stg_customers
    group by customer_number
    ) s
left join k_customers k
  on k.customer_number = s.customer_number
where customer_rk is null
;