-- Revert table_user_company

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE user_company;

COMMIT;
