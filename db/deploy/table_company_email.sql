-- Deploy table_company_email
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TABLE company_email (
        company TEXT NOT NULL,
        email TEXT NOT NULL,
        is_main_address BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY(company, email),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
