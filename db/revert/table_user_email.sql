-- Revert table_user_email

BEGIN;

    SET search_path = 'system';
    SET client_min_messages = 'warning';

    DROP TABLE "user_email";

COMMIT;
