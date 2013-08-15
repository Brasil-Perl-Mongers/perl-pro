-- Revert table_user_role

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE user_role;

COMMIT;
