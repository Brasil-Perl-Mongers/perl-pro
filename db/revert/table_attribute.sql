-- Revert table_attribute

BEGIN;

    DROP TABLE job.attribute;
    DROP TYPE job.attribute_type;

COMMIT;
