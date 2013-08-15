-- Deploy table_user_email
-- requires: table_user
-- requires: schema_perlpro

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    CREATE TABLE "user_email" (
        id SERIAL PRIMARY KEY,
        "user" TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        is_main_address BOOLEAN NOT NULL DEFAULT FALSE,
        FOREIGN KEY("user") REFERENCES "user"(login) ON UPDATE CASCADE ON DELETE CASCADE
    );

COMMIT;
