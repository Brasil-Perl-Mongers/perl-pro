-- Verify table_company_website

BEGIN;

    SELECT company, url FROM company.company_website WHERE FALSE;

ROLLBACK;
