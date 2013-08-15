-- Deploy table_company_phone
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TABLE company_phone (
        company TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_main_phone BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY(company, phone),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
