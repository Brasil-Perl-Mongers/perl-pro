-- Verify table_user_email

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, "user", email, is_main_address FROM user_email WHERE FALSE;

ROLLBACK;
