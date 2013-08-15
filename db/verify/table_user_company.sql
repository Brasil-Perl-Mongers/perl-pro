-- Verify table_user_company

BEGIN;

    SET search_path = 'perlpro';

    SELECT "user", "company" FROM user_company WHERE FALSE;

ROLLBACK;
