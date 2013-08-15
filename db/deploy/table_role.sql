-- Deploy table_role
-- requires: schema_perlpro

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    CREATE TABLE role (
        role_name TEXT PRIMARY KEY
    );

COMMIT;
