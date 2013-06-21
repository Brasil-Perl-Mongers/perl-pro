-- Verify schema_company

BEGIN;

    SELECT pg_catalog.has_schema_privilege('company', 'usage');

ROLLBACK;
