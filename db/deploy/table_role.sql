-- Deploy table_role
-- requires: schema_system

BEGIN;

    SET search_path = 'system';
    SET client_min_messages = 'warning';

    CREATE TABLE role (
        role_name TEXT PRIMARY KEY
    );

COMMIT;
