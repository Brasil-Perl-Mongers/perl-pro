-- Verify schema_job

BEGIN;

    SELECT pg_catalog.has_schema_privilege('job', 'usage');

ROLLBACK;
