-- Verify table_user_company

BEGIN;

    SELECT "user", "company" FROM company.user_company WHERE FALSE;

ROLLBACK;
