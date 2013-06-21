-- Verify table_company

BEGIN;

    SELECT name_in_url, name, description, ctime, mtime, balance FROM "company"."company" WHERE FALSE;

ROLLBACK;
