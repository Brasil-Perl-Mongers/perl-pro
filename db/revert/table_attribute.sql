-- Revert table_attribute

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE attribute;
    DROP TYPE attribute_type;

COMMIT;
