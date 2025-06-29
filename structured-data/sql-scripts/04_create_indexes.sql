-- =====================================================
-- Create Indexes for Performance
-- DCAD Property Appraisal Database Indexes
-- Optimized for common query patterns
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

-- =====================================================
-- ACCOUNT_INFO Indexes
-- =====================================================

-- Index for property location queries
CREATE INDEX idx_account_info_property_city_zip 
ON account_info(property_city, property_zipcode);

-- Index for owner name searches
CREATE INDEX idx_account_info_owner_name1 
ON account_info(owner_name1);

-- Index for GIS parcel lookups
CREATE INDEX idx_account_info_gis_parcel_id 
ON account_info(gis_parcel_id) 
WHERE gis_parcel_id IS NOT NULL;

-- Index for neighborhood searches
CREATE INDEX idx_account_info_nbhd_cd_year 
ON account_info(nbhd_cd, appraisal_yr) 
WHERE nbhd_cd IS NOT NULL;

-- Index for deed transfer date queries
CREATE INDEX idx_account_info_deed_date 
ON account_info(deed_txfr_date) 
WHERE deed_txfr_date IS NOT NULL;

-- =====================================================
-- ACCOUNT_APPRL_YEAR Indexes
-- =====================================================

-- Index for value range queries
CREATE INDEX idx_account_apprl_year_tot_val 
ON account_apprl_year(tot_val) 
WHERE tot_val IS NOT NULL;

-- Index for land value queries
CREATE INDEX idx_account_apprl_year_land_val 
ON account_apprl_year(land_val) 
WHERE land_val IS NOT NULL;

-- Index for improvement value queries
CREATE INDEX idx_account_apprl_year_impr_val 
ON account_apprl_year(impr_val) 
WHERE impr_val IS NOT NULL;

-- Index for jurisdiction queries
CREATE INDEX idx_account_apprl_year_city_taxable 
ON account_apprl_year(city_taxable_val) 
WHERE city_taxable_val IS NOT NULL;

-- Index for building class searches
CREATE INDEX idx_account_apprl_year_bldg_class 
ON account_apprl_year(bldg_class_cd, appraisal_yr) 
WHERE bldg_class_cd IS NOT NULL;

-- Index for revaluation year
CREATE INDEX idx_account_apprl_year_reval_yr 
ON account_apprl_year(reval_yr) 
WHERE reval_yr IS NOT NULL;

-- =====================================================
-- TAXABLE_OBJECT Indexes
-- =====================================================

-- Index for tax object lookups (already covered by PK)
-- Additional composite index for reverse lookups
CREATE INDEX idx_taxable_object_tax_obj_id 
ON taxable_object(tax_obj_id, appraisal_yr);

-- =====================================================
-- RES_DETAIL Indexes
-- =====================================================

-- Index for year built searches
CREATE INDEX idx_res_detail_yr_built 
ON res_detail(yr_built) 
WHERE yr_built IS NOT NULL;

-- Index for living area searches
CREATE INDEX idx_res_detail_living_area 
ON res_detail(tot_living_area_sf) 
WHERE tot_living_area_sf IS NOT NULL;

-- Index for bedrooms/bathrooms searches
CREATE INDEX idx_res_detail_bed_bath 
ON res_detail(num_bedrooms, num_full_baths) 
WHERE num_bedrooms IS NOT NULL AND num_full_baths IS NOT NULL;

-- Index for building class
CREATE INDEX idx_res_detail_bldg_class_year 
ON res_detail(bldg_class_desc, appraisal_yr) 
WHERE bldg_class_desc IS NOT NULL;

-- Index for amenities
CREATE INDEX idx_res_detail_amenities 
ON res_detail(pool_ind, spa_ind, deck_ind) 
WHERE pool_ind IS NOT NULL OR spa_ind IS NOT NULL OR deck_ind IS NOT NULL;

-- =====================================================
-- COM_DETAIL Indexes
-- =====================================================

-- Index for building area searches
CREATE INDEX idx_com_detail_gross_area 
ON com_detail(gross_bldg_area) 
WHERE gross_bldg_area IS NOT NULL;

-- Index for lease area searches
CREATE INDEX idx_com_detail_net_lease_area 
ON com_detail(net_lease_area) 
WHERE net_lease_area IS NOT NULL;

-- Index for market value searches
CREATE INDEX idx_com_detail_mkt_val 
ON com_detail(mkt_val) 
WHERE mkt_val IS NOT NULL;

-- Index for property name searches
CREATE INDEX idx_com_detail_property_name 
ON com_detail(property_name) 
WHERE property_name IS NOT NULL;

-- Index for year built
CREATE INDEX idx_com_detail_year_built 
ON com_detail(year_built) 
WHERE year_built IS NOT NULL;

-- =====================================================
-- LAND Indexes
-- =====================================================

-- Index for area size searches
CREATE INDEX idx_land_area_size 
ON land(area_size) 
WHERE area_size IS NOT NULL;

-- Index for land value searches
CREATE INDEX idx_land_val_amt 
ON land(val_amt) 
WHERE val_amt IS NOT NULL;

-- Index for zoning searches
CREATE INDEX idx_land_zoning_year 
ON land(zoning, appraisal_yr) 
WHERE zoning IS NOT NULL;

-- Index for agricultural use
CREATE INDEX idx_land_ag_use 
ON land(ag_use_ind, appraisal_yr) 
WHERE ag_use_ind = 'Y';

-- Index for state property type
CREATE INDEX idx_land_sptd_cd 
ON land(sptd_cd, appraisal_yr) 
WHERE sptd_cd IS NOT NULL;

-- =====================================================
-- RES_ADDL Indexes
-- =====================================================

-- Index for improvement type searches
CREATE INDEX idx_res_addl_impr_type 
ON res_addl(impr_typ_desc, appraisal_yr) 
WHERE impr_typ_desc IS NOT NULL;

-- Index for improvement value
CREATE INDEX idx_res_addl_val_amt 
ON res_addl(val_amt) 
WHERE val_amt IS NOT NULL;

-- =====================================================
-- MULTI_OWNER Indexes
-- =====================================================

-- Index for owner name searches
CREATE INDEX idx_multi_owner_name 
ON multi_owner(owner_name) 
WHERE owner_name IS NOT NULL;

-- Index for ownership percentage
CREATE INDEX idx_multi_owner_pct 
ON multi_owner(ownership_pct) 
WHERE ownership_pct IS NOT NULL;

-- =====================================================
-- EXEMPTION INDEXES
-- =====================================================

-- APPLIED_STD_EXEMPT Indexes
CREATE INDEX idx_applied_std_exempt_homestead_date 
ON applied_std_exempt(homestead_eff_dt) 
WHERE homestead_eff_dt IS NOT NULL;

CREATE INDEX idx_applied_std_exempt_over65 
ON applied_std_exempt(over65_desc, appraisal_yr) 
WHERE over65_desc IS NOT NULL;

CREATE INDEX idx_applied_std_exempt_disabled 
ON applied_std_exempt(disabled_desc, appraisal_yr) 
WHERE disabled_desc IS NOT NULL;

CREATE INDEX idx_applied_std_exempt_veteran 
ON applied_std_exempt(vet_eff_yr) 
WHERE vet_eff_yr IS NOT NULL;

-- ACCT_EXEMPT_VALUE Indexes
CREATE INDEX idx_acct_exempt_value_exemption_cd 
ON acct_exempt_value(exemption_cd, appraisal_yr);

CREATE INDEX idx_acct_exempt_value_city_val 
ON acct_exempt_value(city_appld_val) 
WHERE city_appld_val IS NOT NULL AND city_appld_val > 0;

-- ABATEMENT_EXEMPT Indexes
CREATE INDEX idx_abatement_exempt_city_years 
ON abatement_exempt(city_eff_yr, city_exp_yr) 
WHERE city_eff_yr IS NOT NULL;

CREATE INDEX idx_abatement_exempt_cnty_years 
ON abatement_exempt(cnty_eff_yr, cnty_exp_yr) 
WHERE cnty_eff_yr IS NOT NULL;

CREATE INDEX idx_abatement_exempt_isd_years 
ON abatement_exempt(isd_eff_yr, isd_exp_yr) 
WHERE isd_eff_yr IS NOT NULL;

-- =====================================================
-- ACCOUNT_TIF Indexes
-- =====================================================

-- Index for TIF zone searches
CREATE INDEX idx_account_tif_zone 
ON account_tif(tif_zone_desc, appraisal_yr) 
WHERE tif_zone_desc IS NOT NULL;

-- Index for TIF effective years
CREATE INDEX idx_account_tif_effective_yr 
ON account_tif(effective_yr, expiration_yr) 
WHERE effective_yr IS NOT NULL;

-- Index for market values
CREATE INDEX idx_account_tif_acct_mkt 
ON account_tif(acct_mkt) 
WHERE acct_mkt IS NOT NULL;

-- =====================================================
-- Composite Indexes for Common Query Patterns
-- =====================================================

-- Property search by location and year
CREATE INDEX idx_property_location_year 
ON account_info(property_city, property_zipcode, appraisal_yr);

-- Value analysis by neighborhood and year
CREATE INDEX idx_value_nbhd_year 
ON account_info(nbhd_cd, appraisal_yr) 
INCLUDE (account_num);

-- Residential property characteristics
CREATE INDEX idx_residential_characteristics 
ON res_detail(appraisal_yr, tot_living_area_sf, num_bedrooms, yr_built) 
WHERE tot_living_area_sf IS NOT NULL;

-- Commercial property characteristics  
CREATE INDEX idx_commercial_characteristics 
ON com_detail(appraisal_yr, gross_bldg_area, mkt_val) 
WHERE gross_bldg_area IS NOT NULL;

-- Exemption analysis
CREATE INDEX idx_exemption_analysis 
ON acct_exempt_value(appraisal_yr, exemption_cd) 
INCLUDE (city_appld_val, cnty_appld_val, isd_appld_val);

\echo 'All indexes created successfully for optimized query performance'