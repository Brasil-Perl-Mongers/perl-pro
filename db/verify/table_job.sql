-- Verify table_job

BEGIN;

    SET search_path = 'perlpro';

    SELECT
        id, created_at, last_modified, expires_at, status, company, title,
        description, vacancies, phone, email, wages, wages_for, hours,
        hours_by, is_telecommute, contract_type, contract_duration
    FROM
        job
    WHERE FALSE;

ROLLBACK;
