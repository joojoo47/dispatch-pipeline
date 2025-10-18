-- Fix production schema and permissions for PECR/PSR dashboard
-- Safe to run multiple times (idempotent)
--
-- What this does:
-- 1) Ensures jobs has consent columns + constraints + indexes
-- 2) Ensures audit_ledger table exists
-- 3) Optionally grants privileges to retool_readonly and retool_writer (if roles exist)

BEGIN;

-- 1) Ensure consent fields exist on jobs
ALTER TABLE public.jobs
  ADD COLUMN IF NOT EXISTS consent_status VARCHAR(20) DEFAULT 'PENDING',
  ADD COLUMN IF NOT EXISTS consent_timestamp TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS is_first_contact BOOLEAN DEFAULT TRUE;

-- Add check constraint only if missing
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint c
    JOIN pg_class t ON t.oid = c.conrelid
    JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname = 'public' AND t.relname = 'jobs' AND c.conname = 'chk_consent_status'
  ) THEN
    ALTER TABLE public.jobs
      ADD CONSTRAINT chk_consent_status
      CHECK (consent_status IN ('PENDING', 'GIVEN', 'DENIED'));
  END IF;
END$$;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_jobs_consent_status ON public.jobs(consent_status);
CREATE INDEX IF NOT EXISTS idx_jobs_phone_consent ON public.jobs(phone, consent_status);

-- 2) Ensure audit_ledger exists
CREATE TABLE IF NOT EXISTS public.audit_ledger (
  id SERIAL PRIMARY KEY,
  event_type VARCHAR(100) NOT NULL,
  contact_id VARCHAR(50),
  message_body TEXT,
  channel VARCHAR(50),
  is_sandbox BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Optional utility function for writing audit entries
CREATE OR REPLACE FUNCTION public.write_audit(
  p_job_id INTEGER,
  p_event_type VARCHAR(100),
  p_contact_id VARCHAR(50),
  p_message_body TEXT,
  p_channel VARCHAR(50)
) RETURNS VOID AS $$
BEGIN
  INSERT INTO public.audit_ledger (event_type, contact_id, message_body, channel, is_sandbox)
  VALUES (p_event_type, p_contact_id, p_message_body, p_channel, FALSE);
END;
$$ LANGUAGE plpgsql;

-- 3) Permissions (grant if roles already exist)
-- Read-only consumer (queries)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'retool_readonly') THEN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO retool_readonly', current_database());
    GRANT USAGE ON SCHEMA public TO retool_readonly;
    GRANT SELECT ON public.jobs TO retool_readonly;
    GRANT SELECT ON public.audit_ledger TO retool_readonly;
  END IF;
END$$;

-- Writer user (mutations)
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'retool_writer') THEN
    EXECUTE format('GRANT CONNECT ON DATABASE %I TO retool_writer', current_database());
    GRANT USAGE ON SCHEMA public TO retool_writer;
    GRANT SELECT, UPDATE (consent_status, consent_timestamp) ON public.jobs TO retool_writer;
    GRANT INSERT ON public.audit_ledger TO retool_writer;
  END IF;
END$$;

COMMIT;

-- NOTE on priority: It's intentionally computed in SQL (CASE expression) and is not a physical column.
