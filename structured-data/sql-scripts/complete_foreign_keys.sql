-- Complete Foreign Key Constraint Implementation
-- This script adds the remaining 6 foreign key constraints
-- Run with extended timeout settings

SET search_path TO appraisal, public;

-- Set longer timeout for large table operations
SET statement_timeout = '30min';

\echo 'Starting foreign key constraint completion...'
\echo 'Current timeout: 30 minutes per operation'

-- =====================================================
-- Step 1: Final data cleanup for any remaining orphans
-- =====================================================
\echo 'Step 1: Cleaning any remaining orphaned records...'

-- Clean account_apprl_year orphans
\echo 'Cleaning account_apprl_year orphans...'
DELETE FROM appraisal.account_apprl_year aay
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.account_info ai 
    WHERE aay.account_num = ai.account_num 
    AND aay.appraisal_yr = ai.appraisal_yr
);

-- Clean acct_exempt_value orphans
\echo 'Cleaning acct_exempt_value orphans...'
DELETE FROM appraisal.acct_exempt_value aev
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.account_info ai 
    WHERE aev.account_num = ai.account_num 
    AND aev.appraisal_yr = ai.appraisal_yr
);

-- Clean account_tif orphans
\echo 'Cleaning account_tif orphans...'
DELETE FROM appraisal.account_tif at
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.account_info ai 
    WHERE at.account_num = ai.account_num 
    AND at.appraisal_yr = ai.appraisal_yr
);

-- Clean res_detail orphans
\echo 'Cleaning res_detail orphans...'
DELETE FROM appraisal.res_detail rd
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.taxable_object to_obj 
    WHERE rd.account_num = to_obj.account_num 
    AND rd.appraisal_yr = to_obj.appraisal_yr 
    AND rd.tax_obj_id = to_obj.tax_obj_id
);

-- Clean com_detail orphans
\echo 'Cleaning com_detail orphans...'
DELETE FROM appraisal.com_detail cd
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.taxable_object to_obj 
    WHERE cd.account_num = to_obj.account_num 
    AND cd.appraisal_yr = to_obj.appraisal_yr 
    AND cd.tax_obj_id = to_obj.tax_obj_id
);

-- Clean res_addl orphans
\echo 'Cleaning res_addl orphans...'
DELETE FROM appraisal.res_addl ra
WHERE NOT EXISTS (
    SELECT 1 FROM appraisal.taxable_object to_obj 
    WHERE ra.account_num = to_obj.account_num 
    AND ra.appraisal_yr = to_obj.appraisal_yr 
    AND ra.tax_obj_id = to_obj.tax_obj_id
);

-- =====================================================
-- Step 2: Create supporting indexes for faster constraint validation
-- =====================================================
\echo 'Step 2: Creating supporting indexes...'

-- Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_account_info_lookup 
ON appraisal.account_info (account_num, appraisal_yr);

CREATE INDEX IF NOT EXISTS idx_taxable_object_lookup 
ON appraisal.taxable_object (account_num, appraisal_yr, tax_obj_id);

-- =====================================================
-- Step 3: Add foreign key constraints
-- =====================================================
\echo 'Step 3: Adding foreign key constraints...'

-- Add account_apprl_year foreign key
\echo 'Adding fk_account_apprl_year_account_info...'
ALTER TABLE appraisal.account_apprl_year 
ADD CONSTRAINT fk_account_apprl_year_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr);

-- Add acct_exempt_value foreign key
\echo 'Adding fk_acct_exempt_value_account_info...'
ALTER TABLE appraisal.acct_exempt_value 
ADD CONSTRAINT fk_acct_exempt_value_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr);

-- Add account_tif foreign key
\echo 'Adding fk_account_tif_account_info...'
ALTER TABLE appraisal.account_tif 
ADD CONSTRAINT fk_account_tif_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES appraisal.account_info(account_num, appraisal_yr);

-- Add res_detail foreign key
\echo 'Adding fk_res_detail_taxable_object...'
ALTER TABLE appraisal.res_detail 
ADD CONSTRAINT fk_res_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id);

-- Add com_detail foreign key
\echo 'Adding fk_com_detail_taxable_object...'
ALTER TABLE appraisal.com_detail 
ADD CONSTRAINT fk_com_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id);

-- Add res_addl foreign key
\echo 'Adding fk_res_addl_taxable_object...'
ALTER TABLE appraisal.res_addl 
ADD CONSTRAINT fk_res_addl_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES appraisal.taxable_object(account_num, appraisal_yr, tax_obj_id);

-- =====================================================
-- Step 4: Verify all constraints are in place
-- =====================================================
\echo 'Step 4: Verifying foreign key constraints...'

SELECT 
    conname as constraint_name,
    conrelid::regclass AS table_name,
    confrelid::regclass AS referenced_table
FROM pg_constraint 
WHERE contype = 'f' 
AND connamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'appraisal')
ORDER BY table_name;

\echo 'Foreign key constraint implementation completed!'
\echo 'Total foreign keys should be: 13'