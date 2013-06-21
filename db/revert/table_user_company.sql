-- Revert table_user_company

BEGIN;

    DROP TABLE company.user_company;

COMMIT;
