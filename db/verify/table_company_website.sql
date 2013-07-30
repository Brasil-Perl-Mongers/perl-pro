-- Verify table_company_website

BEGIN;

    SELECT company, url, is_main_website FROM company.company_website WHERE FALSE;

ROLLBACK;
