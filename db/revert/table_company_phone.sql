-- Revert table_company_phone

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company_phone;

COMMIT;
