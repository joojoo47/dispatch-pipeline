-- Create least-privilege database user for Retool Admin Dashboard
-- This user has SELECT on jobs and audit_ledger, UPDATE only on jobs
-- NO permissions to UPDATE or DELETE audit_ledger (maintains immutability)

-- Connect to n8n_dispatch database first
-- \c n8n_dispatch

-- Create the retool_readonly user
CREATE USER retool_readonly WITH PASSWORD 'SecurePass2025!@#';

-- Grant CONNECT to database
GRANT CONNECT ON DATABASE n8n_dispatch TO retool_readonly;

-- Grant USAGE on schema
GRANT USAGE ON SCHEMA public TO retool_readonly;

-- Grant SELECT on audit_ledger (read-only for compliance auditing)
GRANT SELECT ON audit_ledger TO retool_readonly;

-- Grant SELECT and UPDATE on jobs (for manual overrides)
GRANT SELECT, UPDATE ON jobs TO retool_readonly;

-- Grant SELECT on sequences (needed for job_id references)
GRANT SELECT ON jobs_id_seq TO retool_readonly;

-- Verify permissions (run as superuser)
-- SELECT grantee, privilege_type, table_name FROM information_schema.role_table_grants WHERE grantee = 'retool_readonly';

-- Test the user permissions (run as retool_readonly)
-- SELECT id, phone, status, consent_status FROM jobs LIMIT 5;  -- Should work
-- SELECT id, event_type, contact_id FROM audit_ledger LIMIT 5;  -- Should work
-- UPDATE jobs SET status = 'Test' WHERE id = 1;  -- Should work
-- UPDATE audit_ledger SET event_type = 'Test' WHERE id = 1;  -- Should FAIL