-- =====================================================
-- Create Foreign Key Constraints
-- DCAD Property Appraisal Database Foreign Keys
-- Based on ERD relationships
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

-- =====================================================
-- Foreign Keys for ACCOUNT_APPRL_YEAR
-- =====================================================
ALTER TABLE account_apprl_year 
ADD CONSTRAINT fk_account_apprl_year_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for TAXABLE_OBJECT
-- =====================================================
ALTER TABLE taxable_object 
ADD CONSTRAINT fk_taxable_object_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for RES_DETAIL
-- =====================================================
ALTER TABLE res_detail 
ADD CONSTRAINT fk_res_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for COM_DETAIL
-- =====================================================
ALTER TABLE com_detail 
ADD CONSTRAINT fk_com_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for LAND
-- =====================================================
ALTER TABLE land 
ADD CONSTRAINT fk_land_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for RES_ADDL
-- =====================================================
ALTER TABLE res_addl 
ADD CONSTRAINT fk_res_addl_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for MULTI_OWNER
-- =====================================================
ALTER TABLE multi_owner 
ADD CONSTRAINT fk_multi_owner_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for APPLIED_STD_EXEMPT
-- =====================================================
ALTER TABLE applied_std_exempt 
ADD CONSTRAINT fk_applied_std_exempt_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- Note: Could also reference multi_owner, but owner_seq_num might not always exist in multi_owner
-- ALTER TABLE applied_std_exempt 
-- ADD CONSTRAINT fk_applied_std_exempt_multi_owner 
-- FOREIGN KEY (appraisal_yr, account_num, owner_seq_num) 
-- REFERENCES multi_owner(appraisal_yr, account_num, owner_seq_num)
-- ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for ACCT_EXEMPT_VALUE
-- =====================================================
ALTER TABLE acct_exempt_value 
ADD CONSTRAINT fk_acct_exempt_value_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for ABATEMENT_EXEMPT
-- =====================================================
ALTER TABLE abatement_exempt 
ADD CONSTRAINT fk_abatement_exempt_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for FREEPORT_EXEMPTION
-- =====================================================
ALTER TABLE freeport_exemption 
ADD CONSTRAINT fk_freeport_exemption_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for TOTAL_EXEMPTION
-- =====================================================
ALTER TABLE total_exemption 
ADD CONSTRAINT fk_total_exemption_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

-- =====================================================
-- Foreign Keys for ACCOUNT_TIF
-- =====================================================
ALTER TABLE account_tif 
ADD CONSTRAINT fk_account_tif_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr)
ON DELETE CASCADE;

\echo 'All foreign key constraints created successfully'