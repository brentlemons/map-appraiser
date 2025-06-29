-- =====================================================
-- Create Appraisal Schema
-- DCAD Property Appraisal Database Schema Creation
-- =====================================================

-- Create the appraisal schema
CREATE SCHEMA IF NOT EXISTS appraisal;

-- Set the search path to include the appraisal schema
SET search_path TO appraisal, public;

-- Grant usage on schema to current user
GRANT USAGE ON SCHEMA appraisal TO CURRENT_USER;
GRANT CREATE ON SCHEMA appraisal TO CURRENT_USER;

-- Print confirmation
\echo 'Schema "appraisal" created successfully'
\echo 'Search path set to: appraisal, public'