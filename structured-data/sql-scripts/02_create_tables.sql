-- =====================================================
-- Create Tables with Primary Keys
-- DCAD Property Appraisal Database Tables
-- Based on ERD analysis of DCAD2025_CURRENT structure
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

-- =====================================================
-- Core Property Information Table
-- =====================================================
CREATE TABLE account_info (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    division_cd VARCHAR(10),
    biz_name VARCHAR(255),
    owner_name1 VARCHAR(255),
    owner_name2 VARCHAR(255),
    exclude_owner VARCHAR(1),
    owner_address_line1 VARCHAR(255),
    owner_address_line2 VARCHAR(255),
    owner_address_line3 VARCHAR(255),
    owner_address_line4 VARCHAR(255),
    owner_city VARCHAR(100),
    owner_state VARCHAR(10),
    owner_zipcode VARCHAR(20),
    owner_country VARCHAR(50),
    street_num VARCHAR(20),
    street_half_num VARCHAR(10),
    full_street_name VARCHAR(255),
    bldg_id VARCHAR(50),
    unit_id VARCHAR(50),
    property_city VARCHAR(100),
    property_zipcode VARCHAR(20),
    mapsco VARCHAR(20),
    nbhd_cd VARCHAR(20),
    legal1 TEXT,
    legal2 TEXT,
    legal3 TEXT,
    legal4 TEXT,
    legal5 TEXT,
    deed_txfr_date DATE,
    gis_parcel_id VARCHAR(50),
    phone_num VARCHAR(20),
    lma VARCHAR(50),
    ima VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_account_info PRIMARY KEY (account_num, appraisal_yr)
);

-- =====================================================
-- Annual Appraisal Values Table
-- =====================================================
CREATE TABLE account_apprl_year (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    impr_val DECIMAL(15,2),
    land_val DECIMAL(15,2),
    land_ag_exempt DECIMAL(15,2),
    ag_use_val DECIMAL(15,2),
    tot_val DECIMAL(15,2),
    hmstd_cap_val DECIMAL(15,2),
    reval_yr INTEGER,
    prev_reval_yr INTEGER,
    prev_mkt_val DECIMAL(15,2),
    tot_contrib_amt DECIMAL(15,2),
    taxpayer_rep VARCHAR(255),
    city_juris_desc VARCHAR(255),
    county_juris_desc VARCHAR(255),
    isd_juris_desc VARCHAR(255),
    hospital_juris_desc VARCHAR(255),
    college_juris_desc VARCHAR(255),
    special_dist_juris_desc VARCHAR(255),
    city_split_pct DECIMAL(5,2),
    county_split_pct DECIMAL(5,2),
    isd_split_pct DECIMAL(5,2),
    hospital_split_pct DECIMAL(5,2),
    college_split_pct DECIMAL(5,2),
    special_dist_split_pct DECIMAL(5,2),
    city_taxable_val DECIMAL(15,2),
    county_taxable_val DECIMAL(15,2),
    isd_taxable_val DECIMAL(15,2),
    hospital_taxable_val DECIMAL(15,2),
    college_taxable_val DECIMAL(15,2),
    special_dist_taxable_val DECIMAL(15,2),
    city_ceiling_value DECIMAL(15,2),
    county_ceiling_value DECIMAL(15,2),
    isd_ceiling_value DECIMAL(15,2),
    hospital_ceiling_value DECIMAL(15,2),
    college_ceiling_value DECIMAL(15,2),
    special_dist_ceiling_value DECIMAL(15,2),
    vid_ind VARCHAR(1),
    gis_parcel_id VARCHAR(50),
    appraisal_meth_cd VARCHAR(10),
    rendition_penalty DECIMAL(15,2),
    division_cd VARCHAR(10),
    extrnl_cnty_acct VARCHAR(50),
    extrnl_city_acct VARCHAR(50),
    p_bus_typ_cd VARCHAR(10),
    bldg_class_cd VARCHAR(10),
    sptd_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_account_apprl_year PRIMARY KEY (account_num, appraisal_yr)
);

-- =====================================================
-- Taxable Object Mapping Table
-- =====================================================
CREATE TABLE taxable_object (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    tax_obj_id VARCHAR(50) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_taxable_object PRIMARY KEY (account_num, appraisal_yr, tax_obj_id)
);

-- =====================================================
-- Residential Property Details Table
-- =====================================================
CREATE TABLE res_detail (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    tax_obj_id VARCHAR(50) NOT NULL,
    bldg_class_desc VARCHAR(100),
    yr_built INTEGER,
    eff_yr_built INTEGER,
    act_age INTEGER,
    cdu_rating_desc VARCHAR(50),
    tot_main_sf INTEGER,
    tot_living_area_sf INTEGER,
    pct_complete DECIMAL(5,2),
    num_stories_desc VARCHAR(50),
    constr_fram_typ_desc VARCHAR(100),
    foundation_typ_desc VARCHAR(100),
    heating_typ_desc VARCHAR(100),
    ac_typ_desc VARCHAR(100),
    fence_typ_desc VARCHAR(100),
    ext_wall_desc VARCHAR(100),
    basement_desc VARCHAR(100),
    roof_typ_desc VARCHAR(100),
    roof_mat_desc VARCHAR(100),
    num_fireplaces INTEGER,
    num_kitchens INTEGER,
    num_full_baths INTEGER,
    num_half_baths INTEGER,
    num_wet_bars INTEGER,
    num_bedrooms INTEGER,
    sprinkler_sys_ind VARCHAR(1),
    deck_ind VARCHAR(1),
    spa_ind VARCHAR(1),
    pool_ind VARCHAR(1),
    sauna_ind VARCHAR(1),
    mbl_home_ser_num VARCHAR(50),
    mbl_home_manufctr VARCHAR(100),
    mbl_home_length DECIMAL(8,2),
    mbl_home_width DECIMAL(8,2),
    mbl_home_space VARCHAR(50),
    depreciation_pct DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_res_detail PRIMARY KEY (account_num, appraisal_yr, tax_obj_id)
);

-- =====================================================
-- Commercial Property Details Table
-- =====================================================
CREATE TABLE com_detail (
    tax_obj_id VARCHAR(50) NOT NULL,
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    bldg_class_desc VARCHAR(100),
    year_built INTEGER,
    remodel_yr INTEGER,
    gross_bldg_area INTEGER,
    foundation_typ_desc VARCHAR(100),
    foundation_area INTEGER,
    basement_desc VARCHAR(100),
    basement_area INTEGER,
    num_stories INTEGER,
    constr_typ_desc VARCHAR(100),
    heating_typ_desc VARCHAR(100),
    ac_typ_desc VARCHAR(100),
    num_units INTEGER,
    net_lease_area INTEGER,
    property_name VARCHAR(255),
    property_qual_desc VARCHAR(100),
    property_cond_desc VARCHAR(100),
    phys_depr_pct DECIMAL(5,2),
    funct_depr_pct DECIMAL(5,2),
    extrnl_depr_pct DECIMAL(5,2),
    tot_depr_pct DECIMAL(5,2),
    imp_val DECIMAL(15,2),
    land_val DECIMAL(15,2),
    mkt_val DECIMAL(15,2),
    appr_method_desc VARCHAR(100),
    comparability_cd VARCHAR(10),
    pct_complete DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_com_detail PRIMARY KEY (tax_obj_id, account_num, appraisal_yr)
);

-- =====================================================
-- Land Parcels Table
-- =====================================================
CREATE TABLE land (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    section_num INTEGER NOT NULL,
    sptd_cd VARCHAR(20),
    sptd_desc VARCHAR(255),
    zoning VARCHAR(50),
    front_dim DECIMAL(10,2),
    depth_dim DECIMAL(10,2),
    area_size DECIMAL(15,2),
    area_uom_desc VARCHAR(50),
    pricing_meth_desc VARCHAR(100),
    cost_per_uom DECIMAL(10,2),
    market_adj_pct DECIMAL(5,2),
    val_amt DECIMAL(15,2),
    ag_use_ind VARCHAR(1),
    acct_ag_val_amt DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_land PRIMARY KEY (account_num, appraisal_yr, section_num)
);

-- =====================================================
-- Additional Residential Improvements Table
-- =====================================================
CREATE TABLE res_addl (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    tax_obj_id VARCHAR(50) NOT NULL,
    seq_num INTEGER NOT NULL,
    impr_typ_desc VARCHAR(100),
    impr_desc VARCHAR(255),
    yr_built INTEGER,
    constr_typ_desc VARCHAR(100),
    floor_typ_desc VARCHAR(100),
    ext_wall_desc VARCHAR(100),
    num_stories INTEGER,
    area_size DECIMAL(10,2),
    val_amt DECIMAL(15,2),
    depreciation_pct DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_res_addl PRIMARY KEY (account_num, appraisal_yr, tax_obj_id, seq_num)
);

-- =====================================================
-- Multiple Ownership Table
-- =====================================================
CREATE TABLE multi_owner (
    appraisal_yr INTEGER NOT NULL,
    account_num VARCHAR(50) NOT NULL,
    owner_seq_num INTEGER NOT NULL,
    owner_name VARCHAR(255),
    ownership_pct DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_multi_owner PRIMARY KEY (appraisal_yr, account_num, owner_seq_num)
);

-- =====================================================
-- Standard Exemptions Table
-- =====================================================
CREATE TABLE applied_std_exempt (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    owner_seq_num INTEGER NOT NULL,
    exempt_status_cd VARCHAR(10),
    ownership_pct DECIMAL(5,2),
    applicant_name VARCHAR(255),
    homestead_eff_dt DATE,
    over65_desc VARCHAR(100),
    disabled_desc VARCHAR(100),
    tax_deferred_desc VARCHAR(100),
    city_ceil_tax_val DECIMAL(15,2),
    city_ceil_dt DATE,
    city_ceil_xfer_pct DECIMAL(5,2),
    city_ceil_set_ind VARCHAR(1),
    county_ceil_tax_val DECIMAL(15,2),
    county_ceil_dt DATE,
    county_ceil_xfer_pct DECIMAL(5,2),
    county_ceil_set_ind VARCHAR(1),
    isd_ceil_tax_val DECIMAL(15,2),
    isd_ceil_dt DATE,
    isd_ceil_xfer_pct DECIMAL(5,2),
    isd_ceil_set_ind VARCHAR(1),
    college_ceil_tax_val DECIMAL(15,2),
    college_ceil_dt DATE,
    college_ceil_xfer_pct DECIMAL(5,2),
    college_ceil_set_ind VARCHAR(1),
    disable_eff_dt DATE,
    vet_eff_yr INTEGER,
    vet_disable_pct DECIMAL(5,2),
    vet_flat_amt DECIMAL(15,2),
    vet2_eff_yr INTEGER,
    vet2_disable_pct DECIMAL(5,2),
    vet2_flat_amt DECIMAL(15,2),
    capped_hs_amt DECIMAL(15,2),
    hs_pct DECIMAL(5,2),
    tot_val DECIMAL(15,2),
    prorate_ind VARCHAR(1),
    days_taxable INTEGER,
    prorate_eff_dt DATE,
    prorate_exp_dt DATE,
    prorate_name VARCHAR(255),
    over65_pct DECIMAL(5,2),
    disabledpct DECIMAL(5,2),
    xfer_ind VARCHAR(1),
    circuit_bk_flg VARCHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_applied_std_exempt PRIMARY KEY (account_num, appraisal_yr, owner_seq_num)
);

-- =====================================================
-- Exemption Values by Type Table
-- =====================================================
CREATE TABLE acct_exempt_value (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    exemption_cd VARCHAR(10) NOT NULL,
    sortorder INTEGER,
    exemption VARCHAR(255),
    city_appld_val DECIMAL(15,2),
    cnty_appld_val DECIMAL(15,2),
    isd_appld_val DECIMAL(15,2),
    hospital_appld_val DECIMAL(15,2),
    college_appld_val DECIMAL(15,2),
    spcl_applied_val DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_acct_exempt_value PRIMARY KEY (account_num, appraisal_yr, exemption_cd)
);

-- =====================================================
-- Tax Abatements Table
-- =====================================================
CREATE TABLE abatement_exempt (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    tot_val DECIMAL(15,2),
    city_eff_yr INTEGER,
    city_exp_yr INTEGER,
    city_exemption_pct DECIMAL(5,2),
    city_base_val DECIMAL(15,2),
    city_val_dif DECIMAL(15,2),
    city_exemption_amt DECIMAL(15,2),
    cnty_eff_yr INTEGER,
    cnty_exp_yr INTEGER,
    cnty_exemption_pct DECIMAL(5,2),
    cnty_base_val DECIMAL(15,2),
    cnty_val_dif DECIMAL(15,2),
    cnty_exemption_amt DECIMAL(15,2),
    isd_eff_yr INTEGER,
    isd_exp_yr INTEGER,
    isd_exemption_pct DECIMAL(5,2),
    isd_base_val DECIMAL(15,2),
    isd_val_dif DECIMAL(15,2),
    isd_exemption_amt DECIMAL(15,2),
    coll_eff_yr INTEGER,
    coll_exp_yr INTEGER,
    coll_exemption_pct DECIMAL(5,2),
    coll_base_val DECIMAL(15,2),
    coll_val_dif DECIMAL(15,2),
    coll_exemption_amt DECIMAL(15,2),
    spec_eff_yr INTEGER,
    spec_exp_yr INTEGER,
    spec_exemption_pct DECIMAL(5,2),
    spec_base_val DECIMAL(15,2),
    spec_val_dif DECIMAL(15,2),
    spec_exemption_amt DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_abatement_exempt PRIMARY KEY (account_num, appraisal_yr)
);

-- =====================================================
-- Freeport Exemptions Table
-- =====================================================
CREATE TABLE freeport_exemption (
    appraisal_yr INTEGER NOT NULL,
    account_num VARCHAR(50) NOT NULL,
    late_app_ind VARCHAR(1),
    late_doc_ind VARCHAR(1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_freeport_exemption PRIMARY KEY (appraisal_yr, account_num)
);

-- =====================================================
-- Total Exemption Tracking Table
-- =====================================================
CREATE TABLE total_exemption (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_total_exemption PRIMARY KEY (account_num, appraisal_yr)
);

-- =====================================================
-- Tax Increment Financing Table
-- =====================================================
CREATE TABLE account_tif (
    account_num VARCHAR(50) NOT NULL,
    appraisal_yr INTEGER NOT NULL,
    tif_zone_desc VARCHAR(255),
    effective_yr INTEGER,
    expiration_yr INTEGER,
    acct_mkt DECIMAL(15,2),
    city_pct DECIMAL(5,2),
    city_base_mkt DECIMAL(15,2),
    city_base_taxable DECIMAL(15,2),
    city_acct_taxable DECIMAL(15,2),
    cnty_pct DECIMAL(5,2),
    cnty_base_mkt DECIMAL(15,2),
    cnty_base_taxable DECIMAL(15,2),
    cnty_acct_taxable DECIMAL(15,2),
    isd_pct DECIMAL(5,2),
    isd_base_mkt DECIMAL(15,2),
    isd_base_taxable DECIMAL(15,2),
    isd_acct_taxable DECIMAL(15,2),
    hosp_pct DECIMAL(5,2),
    hosp_base_mkt DECIMAL(15,2),
    hosp_base_taxable DECIMAL(15,2),
    hosp_acct_taxable DECIMAL(15,2),
    coll_pct DECIMAL(5,2),
    coll_base_mkt DECIMAL(15,2),
    coll_base_taxable DECIMAL(15,2),
    coll_acct_taxable DECIMAL(15,2),
    spec_pct DECIMAL(5,2),
    spec_base_mkt DECIMAL(15,2),
    spec_base_taxable DECIMAL(15,2),
    spec_acct_taxable DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary Key
    CONSTRAINT pk_account_tif PRIMARY KEY (account_num, appraisal_yr)
);

\echo 'All tables created successfully with primary keys'