-- Deploy table_job_location
-- requires: table_job

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TABLE job_location (
        job INTEGER NOT NULL,
        latlng POINT,               -- retrieve from some geolocation service
        address TEXT NOT NULL,
        city TEXT NOT NULL,         -- not checked in DB because it's retrieve from some geolocation service
        state TEXT NOT NULL,        -- ^^
        country TEXT NOT NULL,      -- ^^
        PRIMARY KEY(job),
        FOREIGN KEY (job) REFERENCES job(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
