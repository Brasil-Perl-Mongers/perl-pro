-- Revert table_company_email

BEGIN;

    DROP TABLE company.company_email;

COMMIT;
