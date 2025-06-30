-- Drop all foreign key constraints from appraisal schema
SET search_path TO appraisal, public;

-- Drop foreign keys from all tables
ALTER TABLE abatement_exempt DROP CONSTRAINT IF EXISTS fk_abatement_exempt_account_info;
ALTER TABLE account_apprl_year DROP CONSTRAINT IF EXISTS fk_account_apprl_year_account_info;
ALTER TABLE account_tif DROP CONSTRAINT IF EXISTS fk_account_tif_account_info;
ALTER TABLE acct_exempt_value DROP CONSTRAINT IF EXISTS fk_acct_exempt_value_account_info;
ALTER TABLE applied_std_exempt DROP CONSTRAINT IF EXISTS fk_applied_std_exempt_account_info;
ALTER TABLE com_detail DROP CONSTRAINT IF EXISTS fk_com_detail_taxable_object;
ALTER TABLE freeport_exemption DROP CONSTRAINT IF EXISTS fk_freeport_exemption_account_info;
ALTER TABLE land DROP CONSTRAINT IF EXISTS fk_land_account_info;
ALTER TABLE multi_owner DROP CONSTRAINT IF EXISTS fk_multi_owner_account_info;
ALTER TABLE res_addl DROP CONSTRAINT IF EXISTS fk_res_addl_taxable_object;
ALTER TABLE res_detail DROP CONSTRAINT IF EXISTS fk_res_detail_taxable_object;
ALTER TABLE taxable_object DROP CONSTRAINT IF EXISTS fk_taxable_object_account_info;
ALTER TABLE total_exemption DROP CONSTRAINT IF EXISTS fk_total_exemption_account_info;

\echo 'All foreign key constraints have been dropped'