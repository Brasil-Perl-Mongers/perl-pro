-- Revert table_job_location

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE job_location;

COMMIT;
