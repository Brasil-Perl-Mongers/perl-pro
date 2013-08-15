-- Verify table_user_role

BEGIN;

    SET search_path = 'perlpro';

    SELECT "user", "role" FROM user_role WHERE FALSE;

ROLLBACK;
