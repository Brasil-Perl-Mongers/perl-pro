-- Verify table_job_location

BEGIN;

    SET search_path = 'perlpro';

    SELECT job, latlng, address, city, state, country FROM job_location WHERE FALSE;

ROLLBACK;
