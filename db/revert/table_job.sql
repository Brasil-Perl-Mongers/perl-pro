-- Revert table_job

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE job;
    DROP TYPE job_status;

COMMIT;
