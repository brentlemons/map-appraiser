-- =====================================================
-- Expand ALL VARCHAR columns to 500 characters
-- This will prevent ANY length constraint violations
-- =====================================================

SET search_path TO appraisal, public;

-- ABATEMENT_EXEMPT table
ALTER TABLE abatement_exempt ALTER COLUMN account_num TYPE VARCHAR(500);

-- ACCOUNT_APPRL_YEAR table
ALTER TABLE account_apprl_year ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN appraisal_meth_cd TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN city_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN college_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN county_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN division_cd TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN extrnl_city_acct TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN extrnl_cnty_acct TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN gis_parcel_id TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN hospital_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN isd_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN p_bus_typ_cd TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN special_dist_juris_desc TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN sptd_code TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN taxpayer_rep TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN vid_ind TYPE VARCHAR(500);

-- ACCOUNT_INFO table (remaining ones)
ALTER TABLE account_info ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN biz_name TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN bldg_id TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN exclude_owner TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN full_street_name TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN gis_parcel_id TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_address_line1 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_address_line2 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_address_line3 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_address_line4 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_city TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_country TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_name1 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_name2 TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN property_city TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN street_num TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN unit_id TYPE VARCHAR(500);

-- ACCOUNT_TIF table
ALTER TABLE account_tif ALTER COLUMN account_num TYPE VARCHAR(500);

-- ACCT_EXEMPT_VALUE table
ALTER TABLE acct_exempt_value ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE acct_exempt_value ALTER COLUMN exemption TYPE VARCHAR(500);

-- APPLIED_STD_EXEMPT table
ALTER TABLE applied_std_exempt ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN applicant_name TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN circuit_bk_flg TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN city_ceil_set_ind TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN college_ceil_set_ind TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN county_ceil_set_ind TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN exempt_status_cd TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN isd_ceil_set_ind TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN prorate_ind TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN prorate_name TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN tax_deferred_desc TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN xfer_ind TYPE VARCHAR(500);

-- COM_DETAIL table
ALTER TABLE com_detail ALTER COLUMN ac_typ_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN appr_method_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN basement_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN bldg_class_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN comparability_cd TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN constr_typ_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN foundation_typ_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN heating_typ_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN property_cond_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN property_qual_desc TYPE VARCHAR(500);

-- FREEPORT_EXEMPTION table
ALTER TABLE freeport_exemption ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE freeport_exemption ALTER COLUMN late_app_ind TYPE VARCHAR(500);
ALTER TABLE freeport_exemption ALTER COLUMN late_doc_ind TYPE VARCHAR(500);

-- LAND table
ALTER TABLE land ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN area_uom_desc TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN pricing_meth_desc TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN sptd_desc TYPE VARCHAR(500);

-- MULTI_OWNER table
ALTER TABLE multi_owner ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE multi_owner ALTER COLUMN owner_name TYPE VARCHAR(500);

-- RES_ADDL table
ALTER TABLE res_addl ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN constr_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN ext_wall_desc TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN floor_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN impr_desc TYPE VARCHAR(500);

-- RES_DETAIL table
ALTER TABLE res_detail ALTER COLUMN ac_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN account_num TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN basement_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN cdu_rating_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN constr_fram_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN ext_wall_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN fence_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN foundation_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN heating_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN mbl_home_manufctr TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN mbl_home_ser_num TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN mbl_home_space TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN num_stories_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN roof_mat_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN roof_typ_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN sauna_ind TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN sprinkler_sys_ind TYPE VARCHAR(500);

-- TAXABLE_OBJECT table
ALTER TABLE taxable_object ALTER COLUMN account_num TYPE VARCHAR(500);

-- TOTAL_EXEMPTION table
ALTER TABLE total_exemption ALTER COLUMN account_num TYPE VARCHAR(500);

\echo 'ALL VARCHAR columns expanded to 500 characters to prevent length constraint violations'