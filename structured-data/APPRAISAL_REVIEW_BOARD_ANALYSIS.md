# Appraisal Review Board Data Analysis

## Overview

The Appraisal Review Board (ARB) data tracks property tax protests through the official appeal process in Dallas County. This data provides insights into property owner disputes with appraised values and the resolution process.

## Data Source Files

- **Archive File**: `appraisal_review_board_archive.csv` (708.9 MB, 57 columns)
- **Current File**: `appraisal_review_board_current.csv` (148.7 MB, 55 columns)

The archive file is 4.8x larger, suggesting it contains historical data across multiple years while the current file contains recent/active protests.

## Table Schema

**Table Name**: `appraisal.appraisal_review_board`  
**Primary Key**: `(protest_yr, account_num)`

### Column Analysis

#### Identification Fields
- `protest_yr` (INTEGER) - Year of the protest
- `account_num` (VARCHAR(50)) - Property account number linking to `account_info`

#### Contact Information
- `owner_protest_ind` (CHAR(1)) - Indicates if owner filed protest directly
- `mail_name` through `mail_zipcode` - Complete mailing address for correspondence
- `name` (VARCHAR(500)) - Additional name field (archive only)

#### Protest Tracking
- `protest_sent_cdx/dt` - When protest was sent
- `protest_rcvd_cdx/dt` - When protest was received  
- `protest_wd_cdx` - Withdrawal codes
- `late_protest_cdx` - Late filing indicators
- `value_protest_ind` (CHAR(1)) - Value protest flag (archive only)

#### Resolution Process
- `consent_cdx/dt` - Consent agreement status and date
- `resolved_cdx/dt` - Final resolution codes and dates
- `reinspect_req_cdx/dt` - Property reinspection requests

#### Hearing Information
- `hearing_dt/tm` - Scheduled hearing date and time
- `prev_hearing_dt/tm` - Previous hearing information
- `arb_panel`, `prev_arb_panel` - Panel assignments
- `audio_account_num` - Audio recording reference

#### Representative Information
- `auth_tax_rep_id` - Authorized tax representative ID
- `taxpayer_rep_id` (VARCHAR(50)) - Representative ID (archive only)

#### Value Progression
- `notified_val` (DECIMAL(15,2)) - Initial appraised value notification
- `new_val` (DECIMAL(15,2)) - Proposed new value
- `panel_val` (DECIMAL(15,2)) - Final ARB panel determination

#### Procedural Indicators
- Multiple `p2525*_ind` fields - References to specific tax code procedures
- `p4208_ind`, `p41411_ind` - Additional procedure codes
- `hb201_req_ind` - House Bill 201 requirements
- `exempt_protest_desc` - Exemption protest descriptions

#### Administrative Fields
- `cert_mail_num/dt` - Certified mail tracking
- `not_present_ind` - No-show indicators
- `acct_type` - Account type classification
- `active` (BOOLEAN) - Record status (custom addition)

## Data Quality Observations

Based on sample data analysis:

1. **Date Handling**: Many dates use "1900-01-01" as null/empty values
2. **Status Codes**: Single character codes (Y/N, P/F, etc.) for most indicators  
3. **Representative Patterns**: Common representatives like "RESOLUTE PROPERTY TAX SOLUTIONS"
4. **Value Ranges**: Property values range from tens of thousands to millions
5. **Account Types**: Primarily "RES" (residential) and "COM" (commercial)

## Business Process Insights

The ARB process follows this general flow:
1. **Protest Filing** - Owner receives appraisal notice and files protest
2. **Initial Processing** - Protest received and categorized  
3. **Informal Resolution** - Attempt at consent agreement
4. **Formal Hearing** - ARB panel hearing if no informal resolution
5. **Final Determination** - Panel sets final value

## Relationship to Core Data

The ARB table connects to the core appraisal data through:
- `account_num` links to `account_info.account_num`
- `protest_yr` typically corresponds to `appraisal_yr`
- Values reference those in `account_apprl_year` table

## Usage Scenarios

1. **Protest Analysis** - Track success rates and value reductions
2. **Representative Performance** - Analyze effectiveness of tax representatives
3. **Timeline Analysis** - Monitor processing times and bottlenecks
4. **Value Trends** - Compare initial vs final determinations
5. **Compliance Tracking** - Monitor procedural requirements and deadlines

## Implementation Notes

- Table designed to accommodate both current and archive data
- Primary key ensures one protest record per account per year
- Additional indexes on common query fields (account_num, protest_yr, active)
- Archive-specific columns (value_protest_ind, name, taxpayer_rep_id) included
- Custom `active` flag allows for logical deletion without data loss