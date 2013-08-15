-- Deploy table_user_role
-- requires: schema_perlpro
-- requires: table_user
-- requires: table_role

BEGIN;

    SET search_path = 'perlpro';
    SET client_min_messages = 'warning';

    CREATE TABLE user_role (
        "user" TEXT NOT NULL,
        "role" TEXT NOT NULL,
        FOREIGN KEY ("user") REFERENCES "user"(login) ON DELETE CASCADE ON UPDATE CASCADE,
        FOREIGN KEY ("role") REFERENCES "role"(role_name) ON DELETE CASCADE ON UPDATE CASCADE,
        PRIMARY KEY("user", "role")
    );

COMMIT;
