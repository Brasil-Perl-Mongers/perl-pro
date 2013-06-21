-- Revert schema_company

BEGIN;

    DROP SCHEMA company;

COMMIT;
