-- PECR Consent Compliance: Add consent audit fields to jobs table
-- This migration adds fields required for auditable consent mechanisms per PECR Reg. 22

ALTER TABLE jobs
ADD COLUMN IF NOT EXISTS consent_status VARCHAR(20) DEFAULT 'PENDING',
ADD COLUMN IF NOT EXISTS consent_timestamp TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS is_first_contact BOOLEAN DEFAULT TRUE;

-- Create index for efficient consent status queries
CREATE INDEX IF NOT EXISTS idx_jobs_consent_status ON jobs(consent_status);

-- Create index for phone-based consent lookups (used in reply handler)
CREATE INDEX IF NOT EXISTS idx_jobs_phone_consent ON jobs(phone, consent_status);

-- Add constraint to ensure valid consent statuses
ALTER TABLE jobs
ADD CONSTRAINT chk_consent_status
CHECK (consent_status IN ('PENDING', 'GIVEN', 'DENIED'));

-- Update existing jobs to have consent_status = 'GIVEN' (assume prior consent for existing data)
-- NOTE: In production, you may want to review this assumption or set to 'PENDING' and re-contact
UPDATE jobs SET consent_status = 'GIVEN', consent_timestamp = created_at WHERE consent_status IS NULL;

-- Add comment for audit compliance
COMMENT ON COLUMN jobs.consent_status IS 'PECR compliance: Auditable consent status (PENDING/GIVEN/DENIED)';
COMMENT ON COLUMN jobs.consent_timestamp IS 'PECR compliance: Timestamp when consent was given/denied';
COMMENT ON COLUMN jobs.is_first_contact IS 'PECR compliance: Tracks if this is the first contact attempt';