-- Revert table_company_website

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company_website;

COMMIT;
