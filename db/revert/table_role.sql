-- Revert table_role

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    DROP TABLE role;

COMMIT;
