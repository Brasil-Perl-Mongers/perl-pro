-- Revert table_company_feed

BEGIN;

    SET search_path = 'perlpro';

    DROP TABLE company_feed;
    DROP TYPE  company_feed_type;

COMMIT;
