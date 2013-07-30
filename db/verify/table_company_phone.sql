-- Verify table_company_phone

BEGIN;

    SELECT company, phone FROM company.company_phone WHERE FALSE;

ROLLBACK;
