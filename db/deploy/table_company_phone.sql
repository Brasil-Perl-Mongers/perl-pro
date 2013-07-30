-- Deploy table_company_phone
-- requires: schema_company
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'company';

    CREATE TABLE company_phone (
        company TEXT NOT NULL,
        phone TEXT NOT NULL,
        PRIMARY KEY(company, phone),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
