-- Verify table_company_email

BEGIN;

    SELECT company, email, is_main_address FROM company.company_email WHERE FALSE;

ROLLBACK;
