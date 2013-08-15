-- Revert table_user_email

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    DROP TABLE user_email;

COMMIT;
