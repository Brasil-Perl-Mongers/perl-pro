-- Revert table_user_role

BEGIN;

    DROP TABLE "system"."user_role";

COMMIT;
