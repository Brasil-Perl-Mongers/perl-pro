-- Verify table_company_email

BEGIN;

    SELECT company, email FROM company.company_email WHERE FALSE;

ROLLBACK;
