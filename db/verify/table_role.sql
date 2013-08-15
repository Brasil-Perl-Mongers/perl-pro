-- Verify table_role

BEGIN;

    SET search_path = 'perlpro';

    SELECT role_name FROM role WHERE FALSE;

ROLLBACK;
