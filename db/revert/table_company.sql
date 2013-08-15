-- Revert table_company

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company;

COMMIT;
