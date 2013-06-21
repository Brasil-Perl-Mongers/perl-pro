-- Verify table_user_email

BEGIN;

    SELECT id, "user", email, is_main_address FROM "system"."user_email" WHERE FALSE;

ROLLBACK;
