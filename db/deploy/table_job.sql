-- Deploy table_job
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TYPE job_status AS ENUM('active', 'expired', 'canceled');
    CREATE TYPE job_contract_type AS ENUM('clt', 'pj', 'internship', 'other');
    CREATE TYPE job_contract_hours AS ENUM('fulltime', 'parttime', 'internship', 'freelance');

    CREATE TABLE job (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        last_modified TIMESTAMP NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '30 days',
        company TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        salary MONEY NOT NULL,
        location TEXT NOT NULL, -- TODO: should I split this, and validate?
        phone TEXT, -- is this really needed?
        email TEXT, -- is this really needed?
        vacancies INTEGER NOT NULL DEFAULT 1,
        contract_type job_contract_type NOT NULL DEFAULT 'other'::job_contract_type,
        contract_hours job_contract_hours NOT NULL DEFAULT 'freelance'::job_contract_hours,
        contract_duration INTERVAL,
        is_telecommute BOOLEAN NOT NULL DEFAULT FALSE,
        status job_status NOT NULL DEFAULT 'active'::job_status,
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
