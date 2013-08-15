-- Deploy table_user_company
-- requires: schema_perlpro
-- requires: table_user
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'perlpro';

    CREATE TABLE user_company (
        "user" TEXT NOT NULL,
        "company" TEXT NOT NULL,
        PRIMARY KEY ("user", "company"),
        FOREIGN KEY ("user") REFERENCES "user"(login) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY ("company") REFERENCES "company"(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
