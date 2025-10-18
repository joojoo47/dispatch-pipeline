-- Optional: set default privileges so future tables remain compliant
-- Run as a superuser or the owner role that creates tables.

-- Replace <owner_role> with the role that owns the schema/tables
-- Example for Fly.io: the app database owner role

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO retool_readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, UPDATE ON TABLES TO retool_writer;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO retool_writer;
