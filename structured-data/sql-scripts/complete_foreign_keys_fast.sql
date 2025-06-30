-- Fast Foreign Key Constraint Implementation
-- This script adds constraints WITHOUT initial validation for speed
-- Then validates them separately

SET search_path TO appraisal, public;

\echo 'Adding foreign key constraints WITHOUT validation for speed...'

-- Add constraints with NOT VALID flag (instant operation)
\echo 'Adding fk_account_apprl_year_account_info (NOT VALID)...'
ALTER TABLE appraisal.account_apprl_year 
ADD CONSTRAINT fk_account_apprl_year_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr) 
NOT VALID;

\echo 'Adding fk_acct_exempt_value_account_info (NOT VALID)...'
ALTER TABLE appraisal.acct_exempt_value 
ADD CONSTRAINT fk_acct_exempt_value_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr) 
NOT VALID;

\echo 'Adding fk_account_tif_account_info (NOT VALID)...'
ALTER TABLE appraisal.account_tif 
ADD CONSTRAINT fk_account_tif_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr) 
NOT VALID;

\echo 'Adding fk_res_detail_taxable_object (NOT VALID)...'
ALTER TABLE appraisal.res_detail 
ADD CONSTRAINT fk_res_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id) 
NOT VALID;

\echo 'Adding fk_com_detail_taxable_object (NOT VALID)...'
ALTER TABLE appraisal.com_detail 
ADD CONSTRAINT fk_com_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id) 
NOT VALID;

\echo 'Adding fk_res_addl_taxable_object (NOT VALID)...'
ALTER TABLE appraisal.res_addl 
ADD CONSTRAINT fk_res_addl_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id) 
NOT VALID;

\echo 'All constraints added WITHOUT validation. They will enforce on NEW data but not existing data.'
\echo 'To validate existing data later, run: ALTER TABLE <table> VALIDATE CONSTRAINT <constraint_name>;'

-- Show all foreign key constraints
\echo 'Current foreign key constraints:'
SELECT 
    conname as constraint_name,
    CASE WHEN convalidated THEN 'VALIDATED' ELSE 'NOT VALIDATED' END as status,
    conrelid::regclass AS table_name
FROM pg_constraint 
WHERE contype = 'f' 
AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'appraisal')
ORDER BY convalidated DESC, table_name;