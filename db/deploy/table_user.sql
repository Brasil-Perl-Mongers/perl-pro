-- Deploy table_user
-- requires: schema_perlpro

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    CREATE TABLE "user" (
        login TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at  TIMESTAMP NOT NULL DEFAULT NOW(),
        modified_at TIMESTAMP NOT NULL DEFAULT NOW(),
        last_login  TIMESTAMP
    );

COMMIT;
