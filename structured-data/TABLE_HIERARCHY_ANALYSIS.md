# Table Hierarchy Analysis

## Overview

Based on the foreign key relationships and data structure analysis, the DCAD property appraisal database follows a clear hierarchical structure with **`account_info`** serving as the primary foundational table.

## 🏗️ **Table Hierarchy Structure**

### **Primary Table:**
- **`account_info`** - Contains the master property and owner information
  - This is the anchor table that must exist before any other records can be created
  - Contains fundamental property identification and ownership data

### **Direct Dependencies (12 tables reference account_info):**

All of these tables have foreign key constraints directly to `account_info` using the composite key `(account_num, appraisal_yr)`:

1. **`account_apprl_year`** - Annual appraisal values and taxable values by jurisdiction
2. **`taxable_object`** - Links specific structures/improvements to properties (bridge table)
3. **`land`** - Land parcel information and valuations
4. **`multi_owner`** - Multiple ownership records for properties with shared ownership
5. **`applied_std_exempt`** - Standard exemptions (homestead, over-65, disabled, veteran)
6. **`acct_exempt_value`** - Exemption values by type and jurisdiction
7. **`abatement_exempt`** - Tax abatements and incentive programs
8. **`freeport_exemption`** - Freeport exemptions for business inventory
9. **`total_exemption`** - Total exemption tracking across all types
10. **`account_tif`** - Tax Increment Financing zone information
11. **`appraisal_review_board`** - Property tax protest tracking through ARB process
12. **`appraisal_notices`** - Annual appraisal notices with detailed exemption amounts by taxing entity

### **Secondary Dependencies (3 tables reference taxable_object):**

These tables reference `taxable_object` using the composite key `(account_num, appraisal_yr, tax_obj_id)`:

- **`res_detail`** - Detailed residential property characteristics
- **`com_detail`** - Detailed commercial property characteristics  
- **`res_addl`** - Additional residential improvements (garages, pools, decks, etc.)

## 🔑 **Key Design Insights**

### **1. Two-Tier Hierarchy**
The database uses a logical two-tier approach:
- **Tier 1**: Property-level data (references `account_info`)
- **Tier 2**: Structure-level data (references `taxable_object`)

### **2. Composite Key Strategy**
All relationships use `(account_num, appraisal_yr)` as the primary linking mechanism, ensuring:
- Historical data preservation across multiple years
- Proper partitioning of data by assessment year
- Referential integrity across time periods

### **3. Bridge Table Pattern**
`taxable_object` serves as a bridge table that:
- Connects abstract properties to specific physical structures
- Allows multiple buildings/improvements per property
- Enables detailed structure-specific analysis

## 📊 **Data Flow Diagram**

```
account_info (property & owner information)
    ↓ [10 direct foreign key relationships]
├── account_apprl_year (annual appraisal values)
├── land (land parcels & valuations)
├── multi_owner (shared ownership)
├── applied_std_exempt (homestead, over-65, veteran exemptions)
├── acct_exempt_value (exemption values by jurisdiction)
├── abatement_exempt (tax abatements)
├── freeport_exemption (business inventory exemptions)
├── total_exemption (total exemption tracking)
├── account_tif (tax increment financing)
└── taxable_object (specific structures/improvements)
    ↓ [3 secondary foreign key relationships]
    ├── res_detail (residential property details)
    ├── com_detail (commercial property details)
    └── res_addl (additional residential improvements)
```

## 🎯 **Business Logic Rationale**

This hierarchical design aligns perfectly with property appraisal business processes:

### **Level 1: Property Establishment**
1. **Properties must exist first** - Every record starts with `account_info`
2. **Annual assessment** - Each year gets its valuation in `account_apprl_year`
3. **Supporting data** - Land, exemptions, and special programs are attached

### **Level 2: Structure Detail**
1. **Physical structures identified** - `taxable_object` catalogs buildings/improvements
2. **Detailed characteristics** - Specific attributes captured in detail tables
3. **Type-specific analysis** - Residential vs commercial vs additional improvements

### **Level 3: Assessment & Taxation**
1. **Value aggregation** - Individual structure values roll up to property level
2. **Exemption application** - Various exemptions applied at property level
3. **Tax calculation** - Final tax burden calculated using all components

## 📈 **Data Volume by Hierarchy Level**

Based on the loaded data across all years (2019-2025):

### **Primary Level:**
- `account_info`: ~6.0M records (foundation)

### **Tier 1 Supporting Tables:**
- `account_apprl_year`: ~6.0M records (1:1 with account_info)
- `taxable_object`: ~6.1M records (1:1+ with account_info)
- `land`: ~5.1M records (most properties have land)
- Other exemption tables: 100K-2.8M records (subset of properties)

### **Tier 2 Detail Tables:**
- `res_detail`: ~4.6M records (residential structures)
- `com_detail`: ~650K records (commercial structures)
- `res_addl`: ~4.2M records (additional improvements)

## 🔒 **Referential Integrity Status**

All 13 foreign key constraints are currently implemented and enforced:
- ✅ **10 constraints** from supporting tables → `account_info`
- ✅ **3 constraints** from detail tables → `taxable_object`
- ✅ **1 constraint** from `taxable_object` → `account_info`

This ensures complete data integrity and prevents orphaned records at any level of the hierarchy.