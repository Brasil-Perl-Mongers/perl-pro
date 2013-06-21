-- Verify table_company_feed

BEGIN;

    SELECT id, company, happened_at, "type", content FROM company.company_feed WHERE FALSE;

ROLLBACK;
