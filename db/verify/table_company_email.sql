-- Verify table_company_email

BEGIN;

    SET search_path = 'perlpro';

    SELECT company, email, is_main_address FROM company_email WHERE FALSE;

ROLLBACK;
