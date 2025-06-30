-- Restore foreign key constraints after data cleaning
-- These constraints ensure referential integrity

SET search_path TO appraisal, public;

\echo 'Restoring foreign key constraints...'

-- Foreign keys referencing account_info
ALTER TABLE account_apprl_year 
ADD CONSTRAINT fk_account_apprl_year_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE taxable_object 
ADD CONSTRAINT fk_taxable_object_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE land 
ADD CONSTRAINT fk_land_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE multi_owner 
ADD CONSTRAINT fk_multi_owner_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE applied_std_exempt 
ADD CONSTRAINT fk_applied_std_exempt_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE acct_exempt_value 
ADD CONSTRAINT fk_acct_exempt_value_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE abatement_exempt 
ADD CONSTRAINT fk_abatement_exempt_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE freeport_exemption 
ADD CONSTRAINT fk_freeport_exemption_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE total_exemption 
ADD CONSTRAINT fk_total_exemption_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

ALTER TABLE account_tif 
ADD CONSTRAINT fk_account_tif_account_info 
FOREIGN KEY (account_num, appraisal_yr) 
REFERENCES account_info(account_num, appraisal_yr);

-- Foreign keys referencing taxable_object
ALTER TABLE res_detail 
ADD CONSTRAINT fk_res_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id);

ALTER TABLE com_detail 
ADD CONSTRAINT fk_com_detail_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id);

ALTER TABLE res_addl 
ADD CONSTRAINT fk_res_addl_taxable_object 
FOREIGN KEY (account_num, appraisal_yr, tax_obj_id) 
REFERENCES taxable_object(account_num, appraisal_yr, tax_obj_id);

\echo 'All foreign key constraints restored successfully!'