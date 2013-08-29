-- Deploy table_job
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TYPE job_status        AS ENUM('active', 'expired', 'canceled');
    CREATE TYPE job_contract_type AS ENUM('clt', 'pj', 'internship', 'freelance', 'no-contract');
    CREATE TYPE job_hours_by      AS ENUM('day', 'week', 'month', 'project');
    CREATE TYPE job_wages_for     AS ENUM('hour', 'month', 'project');

    CREATE TABLE job (
        id SERIAL PRIMARY KEY,

        -- metadata
        created_at    TIMESTAMP  NOT NULL DEFAULT NOW(),
        last_modified TIMESTAMP  NOT NULL DEFAULT NOW(),
        expires_at    TIMESTAMP  NOT NULL DEFAULT NOW() + INTERVAL '30 days',
        status        job_status NOT NULL DEFAULT 'active'::job_status,

        -- basic info
        company     TEXT NOT NULL,
        title       TEXT NOT NULL,
        description TEXT NOT NULL,
        vacancies   INTEGER NOT NULL DEFAULT 1,
        phone       TEXT,
        email       TEXT,

        -- contract info
        wages             MONEY             NOT NULL,
        wages_for         job_wages_for     NOT NULL DEFAULT 'month'::job_wages_for,
        hours             INTEGER           NOT NULL DEFAULT 40,
        hours_by          job_hours_by      NOT NULL DEFAULT 'weekly',
        is_telecommute    BOOLEAN           NOT NULL DEFAULT FALSE,
        contract_type     job_contract_type NOT NULL DEFAULT 'no-contract'::job_contract_type,
        contract_duration INTERVAL, -- TODO

        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
