-- Verify table_promotion

BEGIN;

    SELECT id, job, status, begins_at, ends_at FROM job.promotion WHERE FALSE;

ROLLBACK;
