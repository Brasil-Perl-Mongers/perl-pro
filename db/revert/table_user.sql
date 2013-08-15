-- Revert table_user

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    DROP TABLE "user";

COMMIT;
