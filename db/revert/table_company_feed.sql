-- Revert table_company_feed

BEGIN;

    DROP TABLE company.company_feed;
    DROP TYPE  company.company_feed_type;

COMMIT;
