CREATE TABLE IF NOT EXISTS codm_loans
(
   loan_rk          NUMERIC(10) PRIMARY KEY,
   loan_number      text,
   customer_rk      NUMERIC(10),
   amount           NUMERIC(10,4),
   term             NUMERIC(4),
   interest_rate    NUMERIC(10,4),
   period_cost      NUMERIC(10,4),
   currency_rk      NUMERIC(10),
   grade            text,
   effective_date   text,
   VALID_FROM_DTTM  TIMESTAMP,
   VALID_TO_DTTM    TIMESTAMP,
   PROCESSED_DTTM   TIMESTAMP
)