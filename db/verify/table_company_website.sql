-- Verify table_company_website

BEGIN;

    SET search_path = 'perlpro';

    SELECT company, url, is_main_website FROM company_website WHERE FALSE;

ROLLBACK;
