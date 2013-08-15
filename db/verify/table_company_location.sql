-- Verify table_company_location

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, is_main_address, address, city, state, country FROM company_location WHERE FALSE;

ROLLBACK;
