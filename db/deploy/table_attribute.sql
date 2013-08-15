-- Deploy table_attribute
-- requires: schema_perlpro
-- requires: table_job

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TYPE attribute_type AS ENUM(
        'required', 'desired'
    );

    CREATE TABLE attribute (
        job INTEGER NOT NULL,
        attribute TEXT NOT NULL,
        required_or_desired attribute_type NOT NULL,
        FOREIGN KEY (job) REFERENCES job(id) ON DELETE CASCADE ON UPDATE CASCADE,
        PRIMARY KEY (job, attribute)
    );

COMMIT;
