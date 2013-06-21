-- Verify table_attribute

BEGIN;

    SELECT job, attribute, required_or_desired FROM job.attribute WHERE FALSE;

ROLLBACK;
