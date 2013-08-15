-- Revert table_company_email

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company_email;

COMMIT;
