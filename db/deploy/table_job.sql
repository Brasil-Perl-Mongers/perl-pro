-- Deploy table_job
-- requires: schema_job
-- requires: schema_company
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'job', 'company';

    CREATE TYPE job.job_status AS ENUM('active', 'expired', 'canceled');

    CREATE TABLE job.job (
        id SERIAL PRIMARY KEY,
        created_at TIMESTAMP NOT NULL DEFAULT NOW(),
        last_modified TIMESTAMP NOT NULL DEFAULT NOW(),
        expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '30 days',
        company TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        salary MONEY NOT NULL,
        location TEXT NOT NULL, -- TODO
        status job_status NOT NULL DEFAULT 'active'::job_status,
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
