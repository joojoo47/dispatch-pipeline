-- Base database schema for dispatch pipeline
-- Creates the core tables: jobs and audit_ledger

-- Jobs table for service dispatch management
CREATE TABLE IF NOT EXISTS jobs (
    id SERIAL PRIMARY KEY,
    job_id VARCHAR(50) UNIQUE NOT NULL,
    phone VARCHAR(20) NOT NULL,
    status VARCHAR(50) DEFAULT 'New',
    consent_status VARCHAR(20) DEFAULT 'PENDING',
    is_first_contact BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    consent_timestamp TIMESTAMP WITH TIME ZONE
);

-- Create unique index on phone for conflict resolution
CREATE UNIQUE INDEX IF NOT EXISTS idx_jobs_phone ON jobs(phone);

-- Audit ledger for compliance tracking
CREATE TABLE IF NOT EXISTS audit_ledger (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    contact_id VARCHAR(50),
    message_body TEXT,
    channel VARCHAR(50),
    is_sandbox BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Function for writing audit entries
CREATE OR REPLACE FUNCTION write_audit(
    p_job_id INTEGER,
    p_event_type VARCHAR(100),
    p_contact_id VARCHAR(50),
    p_message_body TEXT,
    p_channel VARCHAR(50)
) RETURNS VOID AS $$
BEGIN
    INSERT INTO audit_ledger (event_type, contact_id, message_body, channel, is_sandbox)
    VALUES (p_event_type, p_contact_id, p_message_body, p_channel, FALSE);
END;
$$ LANGUAGE plpgsql;