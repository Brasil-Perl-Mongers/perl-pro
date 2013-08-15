-- Revert schema_perlpro

BEGIN;

    DROP SCHEMA perlpro;

COMMIT;
