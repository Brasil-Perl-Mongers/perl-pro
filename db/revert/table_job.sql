-- Revert table_job

BEGIN;

    DROP TABLE job.job;
    DROP TYPE job.job_status;

COMMIT;
