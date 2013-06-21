-- Verify table_role

BEGIN;

    SELECT role_name FROM "system"."role" WHERE FALSE;

ROLLBACK;
