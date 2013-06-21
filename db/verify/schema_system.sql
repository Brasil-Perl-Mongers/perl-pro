-- Verify schema_system

BEGIN;

    SELECT pg_catalog.has_schema_privilege('system', 'usage');

ROLLBACK;
