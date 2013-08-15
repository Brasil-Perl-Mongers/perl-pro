-- Verify table_promotion

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, job, status, begins_at, ends_at FROM promotion WHERE FALSE;

ROLLBACK;
