-- Deploy table_company_location
-- requires: schema_perlpro
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TABLE company_location (
        id SERIAL NOT NULL,
        company TEXT NOT NULL,

        latlng  POINT,              -- retrieve from some geolocation service
        address TEXT,

        city    TEXT NOT NULL,      -- not checked in DB because it's retrieve from some geolocation service
        state   TEXT NOT NULL,      -- ^^
        country TEXT NOT NULL,      -- ^^

        is_main_address BOOLEAN NOT NULL DEFAULT FALSE,
        is_public       BOOLEAN NOT NULL DEFAULT FALSE,

        PRIMARY KEY(id),
        FOREIGN KEY (company) REFERENCES company(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
