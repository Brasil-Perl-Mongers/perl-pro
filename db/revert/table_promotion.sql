-- Revert table_promotion

BEGIN;

    DROP TABLE job.promotion;
    DROP TYPE job.promotion_status;

COMMIT;
