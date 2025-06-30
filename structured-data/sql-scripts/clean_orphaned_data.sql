-- Clean orphaned data to restore foreign key integrity
-- This script removes records that violate foreign key constraints

SET search_path TO appraisal, public;

\echo 'Starting data cleaning process...'

-- Count orphaned records before cleaning
\echo 'Counting orphaned records before cleaning:'

SELECT 'res_detail orphans' as table_type, COUNT(*) as count
FROM appraisal.res_detail rd
LEFT JOIN appraisal.taxable_object to_obj 
    ON rd.account_num = to_obj.account_num 
    AND rd.appraisal_yr = to_obj.appraisal_yr 
    AND rd.tax_obj_id = to_obj.tax_obj_id
WHERE to_obj.account_num IS NULL

UNION ALL

SELECT 'com_detail orphans' as table_type, COUNT(*) as count
FROM appraisal.com_detail cd
LEFT JOIN appraisal.taxable_object to_obj 
    ON cd.account_num = to_obj.account_num 
    AND cd.appraisal_yr = to_obj.appraisal_yr 
    AND cd.tax_obj_id = to_obj.tax_obj_id
WHERE to_obj.account_num IS NULL

UNION ALL

SELECT 'taxable_object orphans' as table_type, COUNT(*) as count
FROM appraisal.taxable_object to_obj
LEFT JOIN appraisal.account_info ai 
    ON to_obj.account_num = ai.account_num 
    AND to_obj.appraisal_yr = ai.appraisal_yr
WHERE ai.account_num IS NULL;

\echo 'Cleaning orphaned records...'

-- 1. Remove orphaned res_detail records
\echo 'Removing orphaned res_detail records...'
DELETE FROM appraisal.res_detail 
WHERE (account_num, appraisal_yr, tax_obj_id) NOT IN (
    SELECT account_num, appraisal_yr, tax_obj_id 
    FROM appraisal.taxable_object
);

-- 2. Remove orphaned com_detail records  
\echo 'Removing orphaned com_detail records...'
DELETE FROM appraisal.com_detail 
WHERE (account_num, appraisal_yr, tax_obj_id) NOT IN (
    SELECT account_num, appraisal_yr, tax_obj_id 
    FROM appraisal.taxable_object
);

-- 3. Remove orphaned res_addl records (if any)
\echo 'Removing orphaned res_addl records...'
DELETE FROM appraisal.res_addl 
WHERE (account_num, appraisal_yr, tax_obj_id) NOT IN (
    SELECT account_num, appraisal_yr, tax_obj_id 
    FROM appraisal.taxable_object
);

-- 4. Remove orphaned taxable_object records
\echo 'Removing orphaned taxable_object records...'
DELETE FROM appraisal.taxable_object 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

-- 5. Clean other child tables that reference account_info
\echo 'Removing orphaned records from other child tables...'

DELETE FROM appraisal.account_apprl_year 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.land 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.multi_owner 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.applied_std_exempt 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.acct_exempt_value 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.abatement_exempt 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.freeport_exemption 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.total_exemption 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

DELETE FROM appraisal.account_tif 
WHERE (account_num, appraisal_yr) NOT IN (
    SELECT account_num, appraisal_yr 
    FROM appraisal.account_info
);

\echo 'Data cleaning completed successfully!'