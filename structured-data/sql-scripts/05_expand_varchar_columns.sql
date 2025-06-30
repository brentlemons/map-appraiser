-- =====================================================
-- Expand VARCHAR Column Sizes for Initial Data Load
-- Temporarily increase VARCHAR sizes to avoid length constraints
-- Run this before loading data, then optimize sizes afterward
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

-- =====================================================
-- ACCOUNT_INFO Table VARCHAR Expansions
-- =====================================================

ALTER TABLE account_info ALTER COLUMN division_cd TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_state TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN owner_zipcode TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN street_half_num TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN property_zipcode TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN mapsco TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN nbhd_cd TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN phone_num TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN lma TYPE VARCHAR(500);
ALTER TABLE account_info ALTER COLUMN ima TYPE VARCHAR(500);

-- =====================================================
-- ACCOUNT_APPRL_YEAR Table VARCHAR Expansions
-- =====================================================

ALTER TABLE account_apprl_year ALTER COLUMN bldg_class_cd TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN appraised_by TYPE VARCHAR(500);
ALTER TABLE account_apprl_year ALTER COLUMN appraised_date TYPE VARCHAR(500);

-- =====================================================
-- TAXABLE_OBJECT Table VARCHAR Expansions
-- =====================================================

ALTER TABLE taxable_object ALTER COLUMN tax_obj_id TYPE VARCHAR(500);

-- =====================================================
-- RES_DETAIL Table VARCHAR Expansions
-- =====================================================

ALTER TABLE res_detail ALTER COLUMN tax_obj_id TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN bldg_class_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN use_code_mapsco TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN use_code_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN roof_cover TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN roof_frame TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN found_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN walls_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN floor_desc TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN heat_type TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN fuel_type TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN ac_type TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN pool_ind TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN spa_ind TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN gar_type TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN deck_ind TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN fence_ind TYPE VARCHAR(500);
ALTER TABLE res_detail ALTER COLUMN fire_place_ind TYPE VARCHAR(500);

-- =====================================================
-- COM_DETAIL Table VARCHAR Expansions
-- =====================================================

ALTER TABLE com_detail ALTER COLUMN tax_obj_id TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN property_name TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN use_code_mapsco TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN use_code_desc TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN lease_type TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN wall_type TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN roof_type TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN foundation TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN heat_ac TYPE VARCHAR(500);
ALTER TABLE com_detail ALTER COLUMN parking_type TYPE VARCHAR(500);

-- =====================================================
-- LAND Table VARCHAR Expansions
-- =====================================================

ALTER TABLE land ALTER COLUMN land_use_cd TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN land_use_desc TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN zoning TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN ag_use_ind TYPE VARCHAR(500);
ALTER TABLE land ALTER COLUMN sptd_cd TYPE VARCHAR(500);

-- =====================================================
-- RES_ADDL Table VARCHAR Expansions
-- =====================================================

ALTER TABLE res_addl ALTER COLUMN tax_obj_id TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN impr_typ_cd TYPE VARCHAR(500);
ALTER TABLE res_addl ALTER COLUMN impr_typ_desc TYPE VARCHAR(500);

-- =====================================================
-- MULTI_OWNER Table VARCHAR Expansions
-- =====================================================

ALTER TABLE multi_owner ALTER COLUMN owner_seq_num TYPE VARCHAR(500);

-- =====================================================
-- APPLIED_STD_EXEMPT Table VARCHAR Expansions
-- =====================================================

ALTER TABLE applied_std_exempt ALTER COLUMN owner_seq_num TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN homestead_desc TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN over65_desc TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN disabled_desc TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN disabled_pct TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN vet_desc TYPE VARCHAR(500);
ALTER TABLE applied_std_exempt ALTER COLUMN vet_pct TYPE VARCHAR(500);

-- =====================================================
-- ACCT_EXEMPT_VALUE Table VARCHAR Expansions
-- =====================================================

ALTER TABLE acct_exempt_value ALTER COLUMN exemption_cd TYPE VARCHAR(500);

-- =====================================================
-- ABATEMENT_EXEMPT Table VARCHAR Expansions
-- =====================================================

ALTER TABLE abatement_exempt ALTER COLUMN abatement_desc TYPE VARCHAR(500);

-- =====================================================
-- FREEPORT_EXEMPTION Table VARCHAR Expansions
-- =====================================================

ALTER TABLE freeport_exemption ALTER COLUMN freeport_desc TYPE VARCHAR(500);

-- =====================================================
-- TOTAL_EXEMPTION Table VARCHAR Expansions
-- =====================================================

ALTER TABLE total_exemption ALTER COLUMN total_exempt_desc TYPE VARCHAR(500);

-- =====================================================
-- ACCOUNT_TIF Table VARCHAR Expansions
-- =====================================================

ALTER TABLE account_tif ALTER COLUMN tif_zone_desc TYPE VARCHAR(500);

\echo 'All VARCHAR columns expanded to 500 characters for initial data load'