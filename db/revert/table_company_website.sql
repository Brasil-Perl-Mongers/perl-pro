-- Revert table_company_website

BEGIN;

    DROP TABLE company.company_website;

COMMIT;
