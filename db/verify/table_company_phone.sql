-- Verify table_company_phone

BEGIN;

    SELECT company, phone, is_main_phone FROM company.company_phone WHERE FALSE;

ROLLBACK;
