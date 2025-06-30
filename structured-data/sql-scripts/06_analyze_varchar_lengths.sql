-- =====================================================
-- Analyze VARCHAR Column Lengths
-- Run this after data load to determine optimal column sizes
-- =====================================================

-- Set the search path
SET search_path TO appraisal, public;

\echo '===== VARCHAR Length Analysis Report ====='
\echo ''

-- =====================================================
-- ACCOUNT_INFO Table Analysis
-- =====================================================

\echo '=== ACCOUNT_INFO Table ==='
SELECT 
    'division_cd' as column_name,
    MAX(LENGTH(division_cd)) as max_length,
    COUNT(DISTINCT division_cd) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE division_cd IS NOT NULL

UNION ALL

SELECT 
    'owner_state' as column_name,
    MAX(LENGTH(owner_state)) as max_length,
    COUNT(DISTINCT owner_state) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE owner_state IS NOT NULL

UNION ALL

SELECT 
    'owner_zipcode' as column_name,
    MAX(LENGTH(owner_zipcode)) as max_length,
    COUNT(DISTINCT owner_zipcode) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE owner_zipcode IS NOT NULL

UNION ALL

SELECT 
    'property_zipcode' as column_name,
    MAX(LENGTH(property_zipcode)) as max_length,
    COUNT(DISTINCT property_zipcode) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE property_zipcode IS NOT NULL

UNION ALL

SELECT 
    'mapsco' as column_name,
    MAX(LENGTH(mapsco)) as max_length,
    COUNT(DISTINCT mapsco) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE mapsco IS NOT NULL

UNION ALL

SELECT 
    'nbhd_cd' as column_name,
    MAX(LENGTH(nbhd_cd)) as max_length,
    COUNT(DISTINCT nbhd_cd) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE nbhd_cd IS NOT NULL

UNION ALL

SELECT 
    'lma' as column_name,
    MAX(LENGTH(lma)) as max_length,
    COUNT(DISTINCT lma) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE lma IS NOT NULL

UNION ALL

SELECT 
    'ima' as column_name,
    MAX(LENGTH(ima)) as max_length,
    COUNT(DISTINCT ima) as distinct_values,
    COUNT(*) as total_rows
FROM account_info
WHERE ima IS NOT NULL

ORDER BY column_name;

-- =====================================================
-- ACCOUNT_APPRL_YEAR Table Analysis
-- =====================================================

\echo ''
\echo '=== ACCOUNT_APPRL_YEAR Table ==='
SELECT 
    'bldg_class_cd' as column_name,
    MAX(LENGTH(bldg_class_cd)) as max_length,
    COUNT(DISTINCT bldg_class_cd) as distinct_values,
    COUNT(*) as total_rows
FROM account_apprl_year
WHERE bldg_class_cd IS NOT NULL

UNION ALL

SELECT 
    'appraised_by' as column_name,
    MAX(LENGTH(appraised_by)) as max_length,
    COUNT(DISTINCT appraised_by) as distinct_values,
    COUNT(*) as total_rows
FROM account_apprl_year
WHERE appraised_by IS NOT NULL

ORDER BY column_name;

-- =====================================================
-- RES_DETAIL Table Analysis
-- =====================================================

\echo ''
\echo '=== RES_DETAIL Table ==='
SELECT 
    'bldg_class_desc' as column_name,
    MAX(LENGTH(bldg_class_desc)) as max_length,
    COUNT(DISTINCT bldg_class_desc) as distinct_values,
    COUNT(*) as total_rows
FROM res_detail
WHERE bldg_class_desc IS NOT NULL

UNION ALL

SELECT 
    'use_code_desc' as column_name,
    MAX(LENGTH(use_code_desc)) as max_length,
    COUNT(DISTINCT use_code_desc) as distinct_values,
    COUNT(*) as total_rows
FROM res_detail
WHERE use_code_desc IS NOT NULL

UNION ALL

SELECT 
    'roof_cover' as column_name,
    MAX(LENGTH(roof_cover)) as max_length,
    COUNT(DISTINCT roof_cover) as distinct_values,
    COUNT(*) as total_rows
FROM res_detail
WHERE roof_cover IS NOT NULL

UNION ALL

SELECT 
    'walls_desc' as column_name,
    MAX(LENGTH(walls_desc)) as max_length,
    COUNT(DISTINCT walls_desc) as distinct_values,
    COUNT(*) as total_rows
FROM res_detail
WHERE walls_desc IS NOT NULL

ORDER BY column_name;

-- =====================================================
-- Sample queries for other frequently used tables
-- =====================================================

\echo ''
\echo '=== COM_DETAIL Table ==='
SELECT 
    'use_code_desc' as column_name,
    MAX(LENGTH(use_code_desc)) as max_length,
    COUNT(DISTINCT use_code_desc) as distinct_values,
    COUNT(*) as total_rows
FROM com_detail
WHERE use_code_desc IS NOT NULL

UNION ALL

SELECT 
    'property_name' as column_name,
    MAX(LENGTH(property_name)) as max_length,
    COUNT(DISTINCT property_name) as distinct_values,
    COUNT(*) as total_rows
FROM com_detail
WHERE property_name IS NOT NULL

ORDER BY column_name;

\echo ''
\echo '=== LAND Table ==='
SELECT 
    'land_use_desc' as column_name,
    MAX(LENGTH(land_use_desc)) as max_length,
    COUNT(DISTINCT land_use_desc) as distinct_values,
    COUNT(*) as total_rows
FROM land
WHERE land_use_desc IS NOT NULL

UNION ALL

SELECT 
    'zoning' as column_name,
    MAX(LENGTH(zoning)) as max_length,
    COUNT(DISTINCT zoning) as distinct_values,
    COUNT(*) as total_rows
FROM land
WHERE zoning IS NOT NULL

ORDER BY column_name;

\echo ''
\echo '===== End of VARCHAR Length Analysis ====='