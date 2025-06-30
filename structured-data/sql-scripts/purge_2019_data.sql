-- Purge all 2019 data from the database
-- Run tables in dependency order (children first)

SET search_path TO appraisal, public;

-- Delete from child tables first
DELETE FROM applied_std_exempt WHERE appraisal_yr = 2019;
DELETE FROM acct_exempt_value WHERE appraisal_yr = 2019;
DELETE FROM abatement_exempt WHERE appraisal_yr = 2019;
DELETE FROM freeport_exemption WHERE appraisal_yr = 2019;
DELETE FROM total_exemption WHERE appraisal_yr = 2019;
DELETE FROM account_tif WHERE appraisal_yr = 2019;
DELETE FROM multi_owner WHERE appraisal_yr = 2019;
DELETE FROM res_addl WHERE appraisal_yr = 2019;
DELETE FROM res_detail WHERE appraisal_yr = 2019;
DELETE FROM com_detail WHERE appraisal_yr = 2019;
DELETE FROM land WHERE appraisal_yr = 2019;
DELETE FROM taxable_object WHERE appraisal_yr = 2019;
DELETE FROM account_apprl_year WHERE appraisal_yr = 2019;
DELETE FROM account_info WHERE appraisal_yr = 2019;

\echo 'All 2019 data has been purged from the database'