-- Revert table_promotion

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE promotion;
    DROP TYPE promotion_status;

COMMIT;
