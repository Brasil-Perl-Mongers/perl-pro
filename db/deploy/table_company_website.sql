-- Deploy table_company_website
-- requires: schema_company
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'company';

    CREATE TABLE company_website (
        company TEXT NOT NULL,
        url TEXT NOT NULL,
        is_main_website BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY(company, url),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
