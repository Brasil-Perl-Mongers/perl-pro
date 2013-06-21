-- Deploy table_promotion
-- requires: schema_job
-- requires: table_job

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'job';

    CREATE TYPE promotion_status AS ENUM(
        'expired',         'active',
        'pending-payment', 'payment-failed',
        'canceled',        'refunded'
    );

    CREATE TABLE promotion (
        id SERIAL PRIMARY KEY,
        job INTEGER NOT NULL,
        status promotion_status NOT NULL DEFAULT 'pending-payment'::promotion_status,
        begins_at TIMESTAMP NOT NULL DEFAULT NOW(),
        ends_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '30 days',
        FOREIGN KEY (job) REFERENCES job(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
