-- Revert schema_system

BEGIN;

    DROP SCHEMA system;

COMMIT;
