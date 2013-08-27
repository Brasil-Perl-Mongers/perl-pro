-- Verify table_company_location

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, company, is_main_address, latlng, address, city, state, country FROM company_location WHERE FALSE;

ROLLBACK;
