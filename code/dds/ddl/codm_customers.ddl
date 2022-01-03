CREATE TABLE IF NOT EXISTS codm_customers
(
   customer_rk      NUMERIC(10) PRIMARY KEY,
   customer_number  text,
   name             text,
   city             text,
   dob              text,
   VALID_FROM_DTTM  TIMESTAMP,
   VALID_TO_DTTM    TIMESTAMP,
   PROCESSED_DTTM   TIMESTAMP
)