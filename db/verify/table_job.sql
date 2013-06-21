-- Verify table_job

BEGIN;

    SELECT id, created_at, last_modified, expires_at, company, title, description, salary, location, status FROM job.job WHERE FALSE;

ROLLBACK;
