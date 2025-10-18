-- Verify schema, permissions, and seed presence

-- Tables
\dt public.jobs
\dt public.audit_ledger

-- jobs columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'jobs'
  AND column_name IN ('consent_status','consent_timestamp','is_first_contact')
ORDER BY column_name;

-- audit_ledger columns (summary)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'audit_ledger'
ORDER BY ordinal_position;

-- Permissions
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='public' AND table_name='jobs'
  AND grantee IN ('retool_readonly','retool_writer')
ORDER BY grantee, privilege_type;

SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='public' AND table_name='audit_ledger'
  AND grantee IN ('retool_readonly','retool_writer')
ORDER BY grantee, privilege_type;

-- Quick data checks (won't fail if empty)
SELECT COUNT(*) AS jobs_total,
       COUNT(*) FILTER (WHERE consent_status='PENDING') AS jobs_pending,
       COUNT(*) FILTER (WHERE consent_status='GIVEN') AS jobs_given
FROM public.jobs;

SELECT COUNT(*) AS audit_events_total
FROM public.audit_ledger;
