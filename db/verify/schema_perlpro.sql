-- Verify schema_perlpro

BEGIN;

    SELECT pg_catalog.has_schema_privilege('perlpro', 'usage');

ROLLBACK;
