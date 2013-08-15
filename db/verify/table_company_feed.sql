-- Verify table_company_feed

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, company, happened_at, "type", content FROM company_feed WHERE FALSE;

ROLLBACK;
