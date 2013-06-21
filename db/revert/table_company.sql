-- Revert table_company

BEGIN;

    DROP TABLE company.company;

COMMIT;
