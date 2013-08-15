-- Verify table_user

BEGIN;

    SET search_path = 'perlpro';

    SELECT login, password, name, created_at, modified_at, last_login FROM "user" WHERE FALSE;

ROLLBACK;
