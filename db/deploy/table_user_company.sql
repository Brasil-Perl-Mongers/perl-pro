-- Deploy table_user_company
-- requires: schema_company
-- requires: schema_system
-- requires: table_user
-- requires: table_company

BEGIN;

    SET client_min_messages = 'warning';
    SET search_path = 'system','company';

    CREATE TABLE company.user_company (
        "user" TEXT NOT NULL,
        "company" TEXT NOT NULL,
        PRIMARY KEY ("user", "company"),
        FOREIGN KEY ("user") REFERENCES "user"(login) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY ("company") REFERENCES "company"(name_in_url) ON DELETE CASCADE ON UPDATE CASCADE
    );

COMMIT;
