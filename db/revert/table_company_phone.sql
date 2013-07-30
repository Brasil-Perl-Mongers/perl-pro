-- Revert table_company_phone

BEGIN;

    DROP TABLE company.company_phone;

COMMIT;
