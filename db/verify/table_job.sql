-- Verify table_job

BEGIN;

    SET search_path = 'perlpro';

    SELECT id, created_at, last_modified, expires_at, company, title, description, salary, location, phone, email, vacancies, contract_type, contract_hours, contract_duration, is_telecommute, status FROM job WHERE FALSE;

ROLLBACK;
