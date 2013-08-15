-- Verify table_company

BEGIN;

    SET search_path = 'perlpro';

    SELECT name_in_url, name, description, ctime, mtime, balance FROM company WHERE FALSE;

ROLLBACK;
