-- Purge ALL data from the database
-- Run tables in dependency order (children first)

SET search_path TO appraisal, public;

-- Delete from child tables first
DELETE FROM applied_std_exempt;
DELETE FROM acct_exempt_value;
DELETE FROM abatement_exempt;
DELETE FROM freeport_exemption;
DELETE FROM total_exemption;
DELETE FROM account_tif;
DELETE FROM multi_owner;
DELETE FROM res_addl;
DELETE FROM res_detail;
DELETE FROM com_detail;
DELETE FROM land;
DELETE FROM taxable_object;
DELETE FROM account_apprl_year;
DELETE FROM account_info;

\echo 'All data has been purged from the database'