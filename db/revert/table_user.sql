-- Revert table_user

BEGIN;

    SET search_path = 'system';
    SET client_min_messages = 'warning';

    DROP TABLE "user";

COMMIT;
