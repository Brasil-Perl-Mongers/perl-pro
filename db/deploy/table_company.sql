-- Deploy table_company
-- requires: schema_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'company';

    CREATE TABLE company (
        name_in_url TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        ctime TIMESTAMP NOT NULL DEFAULT NOW(),
        mtime TIMESTAMP NOT NULL DEFAULT NOW(),
        balance MONEY NOT NULL DEFAULT '0.00'
    );

COMMIT;
