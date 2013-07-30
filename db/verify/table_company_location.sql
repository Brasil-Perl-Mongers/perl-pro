-- Verify table_company_location

BEGIN;

    SELECT id, is_main_address, address, city, state, country FROM company.company_location WHERE FALSE;

ROLLBACK;
