-- Verify table_user_role

BEGIN;

    SELECT "user", "role" FROM "system"."user_role" WHERE FALSE;

ROLLBACK;
