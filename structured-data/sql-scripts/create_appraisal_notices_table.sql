-- Create appraisal_notices table in the appraisal schema
-- This table stores appraisal notice data for both residential/commercial and business personal property

CREATE TABLE IF NOT EXISTS appraisal.appraisal_notices (
    -- Primary key fields
    appraisal_yr INTEGER NOT NULL,
    account_num VARCHAR(50) NOT NULL,
    
    -- Core identification fields
    mailing_number VARCHAR(50),
    
    -- Property value fields
    tot_val DECIMAL(15,2),
    land_val DECIMAL(15,2),
    appraised_val DECIMAL(15,2),
    cap_value DECIMAL(15,2),
    contributory_amt DECIMAL(15,2),
    
    -- Date fields
    hearings_start_date DATE,
    protest_deadline_date DATE,
    hearings_conclude_date DATE,
    
    -- Indicator fields
    bpp_penalty_ind CHAR(1),
    special_inv_penalty_ind CHAR(1),
    homestead_ind CHAR(1),
    
    -- County exemption amounts
    county_hs_amt DECIMAL(15,2),
    county_disabled_amt DECIMAL(15,2),
    county_disabled_vet_amt DECIMAL(15,2),
    county_ag_amt DECIMAL(15,2),
    county_freeport_amt DECIMAL(15,2),
    county_pc_amt DECIMAL(15,2),
    county_low_income_amt DECIMAL(15,2),
    county_git_amt DECIMAL(15,2),
    county_vet100_amt DECIMAL(15,2),
    county_abatement_amt DECIMAL(15,2),
    county_historic_amt DECIMAL(15,2),
    county_vet_home_amt DECIMAL(15,2),
    county_child_care_amt DECIMAL(15,2),
    county_other_amt DECIMAL(15,2),
    
    -- College exemption amounts
    college_hs_amt DECIMAL(15,2),
    college_disabled_amt DECIMAL(15,2),
    college_disabled_vet_amt DECIMAL(15,2),
    college_ag_amt DECIMAL(15,2),
    college_freeport_amt DECIMAL(15,2),
    college_pc_amt DECIMAL(15,2),
    college_low_income_amt DECIMAL(15,2),
    college_git_amt DECIMAL(15,2),
    college_vet100_amt DECIMAL(15,2),
    college_abatement_amt DECIMAL(15,2),
    college_historic_amt DECIMAL(15,2),
    college_vet_home_amt DECIMAL(15,2),
    college_other_amt DECIMAL(15,2),
    
    -- Hospital exemption amounts
    hospital_hs_amt DECIMAL(15,2),
    hospital_disabled_amt DECIMAL(15,2),
    hospital_disabled_vet_amt DECIMAL(15,2),
    hospital_ag_amt DECIMAL(15,2),
    hospital_freeport_amt DECIMAL(15,2),
    hospital_pc_amt DECIMAL(15,2),
    hospital_low_income_amt DECIMAL(15,2),
    hospital_git_amt DECIMAL(15,2),
    hospital_vet100_amt DECIMAL(15,2),
    hospital_abatement_amt DECIMAL(15,2),
    hospital_historic_amt DECIMAL(15,2),
    hospital_vet_home_amt DECIMAL(15,2),
    hospital_other_amt DECIMAL(15,2),
    
    -- City exemption amounts
    city_hs_amt DECIMAL(15,2),
    city_disabled_amt DECIMAL(15,2),
    city_disabled_vet_amt DECIMAL(15,2),
    city_ag_amt DECIMAL(15,2),
    city_freeport_amt DECIMAL(15,2),
    city_pc_amt DECIMAL(15,2),
    city_low_income_amt DECIMAL(15,2),
    city_git_amt DECIMAL(15,2),
    city_vet100_amt DECIMAL(15,2),
    city_abatement_amt DECIMAL(15,2),
    city_historic_amt DECIMAL(15,2),
    city_vet_home_amt DECIMAL(15,2),
    city_child_care_amt DECIMAL(15,2),
    city_other_amt DECIMAL(15,2),
    
    -- ISD exemption amounts
    isd_hs_amt DECIMAL(15,2),
    isd_disabled_amt DECIMAL(15,2),
    isd_disabled_vet_amt DECIMAL(15,2),
    isd_ag_amt DECIMAL(15,2),
    isd_freeport_amt DECIMAL(15,2),
    isd_pc_amt DECIMAL(15,2),
    isd_low_income_amt DECIMAL(15,2),
    isd_git_amt DECIMAL(15,2),
    isd_vet100_amt DECIMAL(15,2),
    isd_abatement_amt DECIMAL(15,2),
    isd_historic_amt DECIMAL(15,2),
    isd_vet_home_amt DECIMAL(15,2),
    isd_other_amt DECIMAL(15,2),
    
    -- Special district exemption amounts
    special_hs_amt DECIMAL(15,2),
    special_disabled_amt DECIMAL(15,2),
    special_disabled_vet_amt DECIMAL(15,2),
    special_ag_amt DECIMAL(15,2),
    special_freeport_amt DECIMAL(15,2),
    special_pc_amt DECIMAL(15,2),
    special_low_income_amt DECIMAL(15,2),
    special_git_amt DECIMAL(15,2),
    special_vet100_amt DECIMAL(15,2),
    special_abatement_amt DECIMAL(15,2),
    special_historic_amt DECIMAL(15,2),
    special_vet_home_amt DECIMAL(15,2),
    special_other_amt DECIMAL(15,2),
    
    -- Property type indicator (added to distinguish between file sources)
    property_type VARCHAR(20) NOT NULL, -- 'RES_COM' or 'BPP'
    
    -- Audit fields
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary key constraint
    CONSTRAINT pk_appraisal_notices PRIMARY KEY (appraisal_yr, account_num, property_type)
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_appraisal_notices_account_num ON appraisal.appraisal_notices(account_num);
CREATE INDEX IF NOT EXISTS idx_appraisal_notices_appraisal_yr ON appraisal.appraisal_notices(appraisal_yr);
CREATE INDEX IF NOT EXISTS idx_appraisal_notices_property_type ON appraisal.appraisal_notices(property_type);

-- Add table comment
COMMENT ON TABLE appraisal.appraisal_notices IS 'Stores appraisal notice data for both residential/commercial and business personal property';
COMMENT ON COLUMN appraisal.appraisal_notices.property_type IS 'Property type: RES_COM for residential/commercial, BPP for business personal property';