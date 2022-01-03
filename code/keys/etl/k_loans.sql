insert into k_loans
select row_number() over(order by s.loan_number) as loan_rk, s.loan_number
from (
    select loan_number from stg_loans
    group by loan_number
    ) s
left join k_loans k
  on k.loan_number = s.loan_number
where k.loan_rk is null
;