-- Optional: targeted permissions grants for Retool roles
-- Run after fix_prod_schema.sql. Safe to run multiple times.

BEGIN;

-- Ensure schema usage for both roles if they exist
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'retool_readonly') THEN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO retool_readonly', current_database());
    GRANT USAGE ON SCHEMA public TO retool_readonly;
    -- Minimal least-privilege: only the needed tables
    GRANT SELECT ON public.jobs TO retool_readonly;
    GRANT SELECT ON public.audit_ledger TO retool_readonly;
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'retool_writer') THEN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO retool_writer', current_database());
    GRANT USAGE ON SCHEMA public TO retool_writer;
    GRANT SELECT, UPDATE (consent_status, consent_timestamp) ON public.jobs TO retool_writer;
    GRANT INSERT ON public.audit_ledger TO retool_writer;
    -- Inserts into serial/identity tables need sequence usage
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO retool_writer;
  END IF;
END$$;

COMMIT;
