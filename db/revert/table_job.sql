-- Revert table_job

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE job;
    DROP TYPE job_status;
    DROP TYPE job_contract_type;
    DROP TYPE job_contract_hours_period;

COMMIT;
