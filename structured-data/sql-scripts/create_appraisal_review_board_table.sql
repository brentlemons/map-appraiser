-- Create appraisal_review_board table
-- Based on the archive CSV file structure with 57 columns
-- Primary key: (protest_yr, account_num)

CREATE TABLE appraisal.appraisal_review_board (
    -- Primary key fields
    protest_yr INTEGER NOT NULL,
    account_num VARCHAR(50) NOT NULL,
    
    -- Owner and contact information
    owner_protest_ind CHAR(1),
    mail_name VARCHAR(500),
    mail_addr_l1 VARCHAR(500),
    mail_addr_l2 VARCHAR(500),
    mail_addr_l3 VARCHAR(500),
    mail_city VARCHAR(500),
    mail_state_cd VARCHAR(20),
    mail_zipcode VARCHAR(20),
    
    -- Protest status indicators
    not_present_ind CHAR(1),
    late_protest_cdx VARCHAR(10),
    protest_sent_cdx VARCHAR(10),
    protest_sent_dt TIMESTAMP,
    protest_wd_cdx VARCHAR(10),
    protest_rcvd_cdx VARCHAR(10),
    protest_rcvd_dt TIMESTAMP,
    
    -- Resolution and consent information
    consent_cdx VARCHAR(10),
    consent_dt TIMESTAMP,
    reinspect_req_cdx VARCHAR(10),
    reinspect_dt TIMESTAMP,
    resolved_cdx VARCHAR(10),
    resolved_dt TIMESTAMP,
    exempt_protest_desc VARCHAR(500),
    
    -- Previous hearing information
    prev_sch_cdx VARCHAR(10),
    prev_hearing_dt DATE,
    prev_hearing_tm VARCHAR(20),
    prev_arb_panel VARCHAR(10),
    
    -- Mail and tracking
    cert_mail_num VARCHAR(50),
    value_protest_ind CHAR(1), -- Additional column in archive
    
    -- Various indicator flags
    lessee_ind CHAR(1),
    hb201_req_ind CHAR(1),
    arb_protest_ind CHAR(1),
    p2525c1_ind VARCHAR(10),
    p2525d_ind CHAR(1),
    p41411_ind CHAR(1),
    p4208_ind CHAR(1),
    taxpayer_info_ind CHAR(1),
    consent_onreq_ind CHAR(1),
    exempt_ind CHAR(1),
    
    -- Representative information
    auth_tax_rep_id VARCHAR(50),
    
    -- Hearing details
    arb_panel VARCHAR(10),
    hearing_dt DATE,
    hearing_tm VARCHAR(20),
    exempt_ag_final_orders_cd VARCHAR(10),
    audio_account_num VARCHAR(50),
    final_order_comment VARCHAR(500),
    
    -- Additional procedure indicators
    p2525h_ind CHAR(1),
    p2525c2_ind CHAR(1),
    p2525c3_ind CHAR(1),
    p2525b_ind CHAR(1),
    
    -- Additional dates and values
    cert_mail_dt DATE,
    notified_val DECIMAL(15,2),
    new_val DECIMAL(15,2),
    panel_val DECIMAL(15,2),
    
    -- Account type and additional info
    acct_type VARCHAR(10),
    name VARCHAR(500), -- Additional column in archive
    taxpayer_rep_id VARCHAR(50), -- Additional column in archive
    
    -- Custom fields
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Primary key constraint
    CONSTRAINT pk_appraisal_review_board PRIMARY KEY (protest_yr, account_num)
);

-- Create indexes for common queries
CREATE INDEX idx_arb_account_num ON appraisal.appraisal_review_board (account_num);
CREATE INDEX idx_arb_protest_yr ON appraisal.appraisal_review_board (protest_yr);
CREATE INDEX idx_arb_active ON appraisal.appraisal_review_board (active);
CREATE INDEX idx_arb_resolved_dt ON appraisal.appraisal_review_board (resolved_dt);
CREATE INDEX idx_arb_hearing_dt ON appraisal.appraisal_review_board (hearing_dt);

-- Add table comment
COMMENT ON TABLE appraisal.appraisal_review_board IS 'Appraisal Review Board protest data tracking property tax protests through the ARB process';