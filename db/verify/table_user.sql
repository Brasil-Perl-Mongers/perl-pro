-- Verify table_user

BEGIN;

    SELECT login, password, name, created_at, modified_at, last_login FROM "system"."user" WHERE FALSE;

ROLLBACK;
