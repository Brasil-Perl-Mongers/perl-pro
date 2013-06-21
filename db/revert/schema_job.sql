-- Revert schema_job

BEGIN;

    DROP SCHEMA job;

COMMIT;
