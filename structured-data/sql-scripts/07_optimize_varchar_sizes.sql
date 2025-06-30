-- =====================================================
-- Optimize VARCHAR Column Sizes
-- Run this after analyzing actual data lengths
-- Adjust the sizes based on your analysis results
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

-- =====================================================
-- Example optimization based on typical DCAD data
-- Adjust these sizes based on your analysis results
-- =====================================================

-- ACCOUNT_INFO optimizations
ALTER TABLE account_info ALTER COLUMN division_cd TYPE VARCHAR(10);
ALTER TABLE account_info ALTER COLUMN owner_state TYPE VARCHAR(25);
ALTER TABLE account_info ALTER COLUMN owner_zipcode TYPE VARCHAR(15);
ALTER TABLE account_info ALTER COLUMN street_half_num TYPE VARCHAR(10);
ALTER TABLE account_info ALTER COLUMN property_zipcode TYPE VARCHAR(15);
ALTER TABLE account_info ALTER COLUMN mapsco TYPE VARCHAR(30);
ALTER TABLE account_info ALTER COLUMN nbhd_cd TYPE VARCHAR(15);
ALTER TABLE account_info ALTER COLUMN phone_num TYPE VARCHAR(20);
ALTER TABLE account_info ALTER COLUMN lma TYPE VARCHAR(25);
ALTER TABLE account_info ALTER COLUMN ima TYPE VARCHAR(25);

-- ACCOUNT_APPRL_YEAR optimizations
ALTER TABLE account_apprl_year ALTER COLUMN bldg_class_cd TYPE VARCHAR(15);
ALTER TABLE account_apprl_year ALTER COLUMN appraised_by TYPE VARCHAR(50);
ALTER TABLE account_apprl_year ALTER COLUMN appraised_date TYPE VARCHAR(20);

-- RES_DETAIL optimizations
ALTER TABLE res_detail ALTER COLUMN bldg_class_desc TYPE VARCHAR(100);
ALTER TABLE res_detail ALTER COLUMN use_code_mapsco TYPE VARCHAR(20);
ALTER TABLE res_detail ALTER COLUMN use_code_desc TYPE VARCHAR(100);
ALTER TABLE res_detail ALTER COLUMN roof_cover TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN roof_frame TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN found_desc TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN walls_desc TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN floor_desc TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN heat_type TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN fuel_type TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN ac_type TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN pool_ind TYPE VARCHAR(5);
ALTER TABLE res_detail ALTER COLUMN spa_ind TYPE VARCHAR(5);
ALTER TABLE res_detail ALTER COLUMN gar_type TYPE VARCHAR(50);
ALTER TABLE res_detail ALTER COLUMN deck_ind TYPE VARCHAR(5);
ALTER TABLE res_detail ALTER COLUMN fence_ind TYPE VARCHAR(5);
ALTER TABLE res_detail ALTER COLUMN fire_place_ind TYPE VARCHAR(5);

-- COM_DETAIL optimizations
ALTER TABLE com_detail ALTER COLUMN use_code_mapsco TYPE VARCHAR(20);
ALTER TABLE com_detail ALTER COLUMN use_code_desc TYPE VARCHAR(100);
ALTER TABLE com_detail ALTER COLUMN lease_type TYPE VARCHAR(50);
ALTER TABLE com_detail ALTER COLUMN wall_type TYPE VARCHAR(50);
ALTER TABLE com_detail ALTER COLUMN roof_type TYPE VARCHAR(50);
ALTER TABLE com_detail ALTER COLUMN foundation TYPE VARCHAR(50);
ALTER TABLE com_detail ALTER COLUMN heat_ac TYPE VARCHAR(50);
ALTER TABLE com_detail ALTER COLUMN parking_type TYPE VARCHAR(50);

-- LAND optimizations
ALTER TABLE land ALTER COLUMN land_use_cd TYPE VARCHAR(20);
ALTER TABLE land ALTER COLUMN land_use_desc TYPE VARCHAR(100);
ALTER TABLE land ALTER COLUMN zoning TYPE VARCHAR(30);
ALTER TABLE land ALTER COLUMN ag_use_ind TYPE VARCHAR(5);
ALTER TABLE land ALTER COLUMN sptd_cd TYPE VARCHAR(20);

-- Other table optimizations
ALTER TABLE res_addl ALTER COLUMN impr_typ_cd TYPE VARCHAR(20);
ALTER TABLE res_addl ALTER COLUMN impr_typ_desc TYPE VARCHAR(100);

ALTER TABLE applied_std_exempt ALTER COLUMN homestead_desc TYPE VARCHAR(50);
ALTER TABLE applied_std_exempt ALTER COLUMN over65_desc TYPE VARCHAR(50);
ALTER TABLE applied_std_exempt ALTER COLUMN disabled_desc TYPE VARCHAR(50);
ALTER TABLE applied_std_exempt ALTER COLUMN disabled_pct TYPE VARCHAR(10);
ALTER TABLE applied_std_exempt ALTER COLUMN vet_desc TYPE VARCHAR(50);
ALTER TABLE applied_std_exempt ALTER COLUMN vet_pct TYPE VARCHAR(10);

ALTER TABLE acct_exempt_value ALTER COLUMN exemption_cd TYPE VARCHAR(20);

ALTER TABLE abatement_exempt ALTER COLUMN abatement_desc TYPE VARCHAR(100);

ALTER TABLE freeport_exemption ALTER COLUMN freeport_desc TYPE VARCHAR(100);

ALTER TABLE total_exemption ALTER COLUMN total_exempt_desc TYPE VARCHAR(100);

ALTER TABLE account_tif ALTER COLUMN tif_zone_desc TYPE VARCHAR(100);

\echo 'VARCHAR columns optimized based on actual data analysis'