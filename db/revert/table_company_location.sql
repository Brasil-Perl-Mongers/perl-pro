-- Revert table_company_location

BEGIN;

    DROP TABLE company.company_location;

COMMIT;
