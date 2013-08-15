-- Verify table_attribute

BEGIN;

    SET search_path = 'perlpro';

    SELECT job, attribute, required_or_desired FROM attribute WHERE FALSE;

ROLLBACK;
