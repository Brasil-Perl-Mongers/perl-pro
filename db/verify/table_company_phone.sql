-- Verify table_company_phone

BEGIN;

    SET search_path = 'perlpro';

    SELECT company, phone, is_main_phone, is_public FROM company_phone WHERE FALSE;

ROLLBACK;
