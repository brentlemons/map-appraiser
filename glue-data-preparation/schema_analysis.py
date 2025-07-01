#!/usr/bin/env python3
"""Analyze and categorize the schema columns"""

columns = """APPRAISAL_YR,ACCOUNT_NUM,MAILING_NUMBER,TOT_VAL,LAND_VAL,COUNTY_HS_AMT,COLLEGE_HS_AMT,HOSPITAL_HS_AMT,CITY_HS_AMT,ISD_HS_AMT,SPECIAL_HS_AMT,COUNTY_DISABLED_AMT,COLLEGE_DISABLED_AMT,HOSPITAL_DISABLED_AMT,CITY_DISABLED_AMT,ISD_DISABLED_AMT,SPECIAL_DISABLED_AMT,COUNTY_DISABLED_VET_AMT,COLLEGE_DISABLED_VET_AMT,HOSPITAL_DISABLED_VET_AMT,CITY_DISABLED_VET_AMT,ISD_DISABLED_VET_AMT,SPECIAL_DISABLED_VET_AMT,COUNTY_AG_AMT,COLLEGE_AG_AMT,HOSPITAL_AG_AMT,CITY_AG_AMT,ISD_AG_AMT,SPECIAL_AG_AMT,COUNTY_FREEPORT_AMT,COLLEGE_FREEPORT_AMT,HOSPITAL_FREEPORT_AMT,CITY_FREEPORT_AMT,ISD_FREEPORT_AMT,SPECIAL_FREEPORT_AMT,COUNTY_PC_AMT,COLLEGE_PC_AMT,HOSPITAL_PC_AMT,CITY_PC_AMT,ISD_PC_AMT,SPECIAL_PC_AMT,COUNTY_LOW_INCOME_AMT,COLLEGE_LOW_INCOME_AMT,HOSPITAL_LOW_INCOME_AMT,CITY_LOW_INCOME_AMT,ISD_LOW_INCOME_AMT,SPECIAL_LOW_INCOME_AMT,COUNTY_GIT_AMT,COLLEGE_GIT_AMT,HOSPITAL_GIT_AMT,CITY_GIT_AMT,ISD_GIT_AMT,SPECIAL_GIT_AMT,COUNTY_TOTAL_AMT,COLLEGE_TOTAL_AMT,HOSPITAL_TOTAL_AMT,CITY_TOTAL_AMT,ISD_TOTAL_AMT,SPECIAL_TOTAL_AMT,COUNTY_VET100_AMT,COLLEGE_VET100_AMT,HOSPITAL_VET100_AMT,CITY_VET100_AMT,ISD_VET100_AMT,SPECIAL_VET100_AMT,HEARINGS_START_DATE,PROTEST_DEADLINE_DATE,HEARINGS_CONCLUDE_DATE,CAP_VALUE,CONTRIBUTORY_AMT,BPP_PENALTY_IND,SPECIAL_INV_PENALTY_IND,HOMESTEAD_IND,COUNTY_ABATEMENT_AMT,COLLEGE_ABATEMENT_AMT,HOSPITAL_ABATEMENT_AMT,CITY_ABATEMENT_AMT,ISD_ABATEMENT_AMT,SPECIAL_ABATEMENT_AMT,COUNTY_HISTORIC_AMT,COLLEGE_HISTORIC_AMT,HOSPITAL_HISTORIC_AMT,CITY_HISTORIC_AMT,ISD_HISTORIC_AMT,SPECIAL_HISTORIC_AMT,APPRAISED_VAL,COUNTY_VET_HOME_AMT,COLLEGE_VET_HOME_AMT,HOSPITAL_VET_HOME_AMT,CITY_VET_HOME_AMT,ISD_VET_HOME_AMT,SPECIAL_VET_HOME_AMT,COUNTY_CHILD_CARE_AMT,CITY_CHILD_CARE_AMT"""

column_list = columns.split(',')

# Categorize columns
categories = {
    'Core Fields': [],
    'Taxing Entities': ['COUNTY', 'COLLEGE', 'HOSPITAL', 'CITY', 'ISD', 'SPECIAL'],
    'Exemption Types': {
        'HS': 'Homestead',
        'DISABLED': 'Disabled',
        'DISABLED_VET': 'Disabled Veteran', 
        'AG': 'Agricultural',
        'FREEPORT': 'Freeport',
        'PC': 'Pollution Control',
        'LOW_INCOME': 'Low Income',
        'GIT': 'Goods in Transit',
        'TOTAL': 'Total Exemptions',
        'VET100': '100% Disabled Veteran',
        'ABATEMENT': 'Tax Abatement',
        'HISTORIC': 'Historic',
        'VET_HOME': 'Veteran Home',
        'CHILD_CARE': 'Child Care'
    },
    'Dates': [],
    'Other Fields': []
}

# Identify core fields
core_fields = ['APPRAISAL_YR', 'ACCOUNT_NUM', 'MAILING_NUMBER', 'TOT_VAL', 'LAND_VAL', 'APPRAISED_VAL']

# Identify date fields
date_fields = ['HEARINGS_START_DATE', 'PROTEST_DEADLINE_DATE', 'HEARINGS_CONCLUDE_DATE']

# Identify other fields
other_fields = ['CAP_VALUE', 'CONTRIBUTORY_AMT', 'BPP_PENALTY_IND', 'SPECIAL_INV_PENALTY_IND', 'HOMESTEAD_IND']

print("=== SCHEMA STRUCTURE ANALYSIS ===\n")

print("1. CORE FIELDS (6 columns):")
for field in core_fields:
    print(f"   - {field}")

print("\n2. DATE FIELDS (3 columns):")
for field in date_fields:
    print(f"   - {field}")

print("\n3. OTHER FIELDS (5 columns):")
for field in other_fields:
    print(f"   - {field}")

print("\n4. EXEMPTION AMOUNT FIELDS (80 columns):")
print("   These follow the pattern: [TAXING_ENTITY]_[EXEMPTION_TYPE]_AMT")
print("\n   Taxing Entities (6):")
for entity in categories['Taxing Entities']:
    print(f"   - {entity}")

print("\n   Exemption Types (14):")
for code, description in categories['Exemption Types'].items():
    # Count how many columns have this exemption type
    count = sum(1 for col in column_list if f'_{code}_AMT' in col)
    if count > 0:
        print(f"   - {code:12} ({description}): {count} columns")

print("\n=== SUMMARY ===")
print(f"Total columns: {len(column_list)}")
print(f"- Core fields: 6")
print(f"- Date fields: 3") 
print(f"- Other fields: 5")
print(f"- Exemption amount fields: 80")
print("\nNote: CHILD_CARE exemption only applies to COUNTY and CITY (2 columns instead of 6)")
print("\nBoth BPP and RES_COM files share identical schemas!")