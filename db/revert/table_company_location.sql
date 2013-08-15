-- Revert table_company_location

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company_location;

COMMIT;
