-- Deploy table_company_location
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    -- TODO: maybe link with Google Maps

    CREATE TABLE company_location (
        id SERIAL NOT NULL,
        company TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,         -- TODO: foreign key to check against existing Brazilian cities?
        state TEXT NOT NULL,        -- TODO: foreign key to check against existing Brazilian states?
        country TEXT NOT NULL,      -- TODO: foreign key to check against existing countries?
        is_main_address BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY(id),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
