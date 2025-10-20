-- Test data for Neon migration
-- Insert 5 jobs and 3 audit records

INSERT INTO jobs (job_id, phone, status, consent_status, is_first_contact, created_at, consent_timestamp) VALUES
('job-001', '+1234567890', 'New', 'PENDING', true, NOW() - INTERVAL '2 days', NULL),
('job-002', '+1234567891', 'New', 'PENDING', true, NOW() - INTERVAL '1 day', NULL),
('job-003', '+1234567892', 'New', 'GIVEN', false, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
('job-004', '+1234567893', 'New', 'PENDING', true, NOW() - INTERVAL '4 hours', NULL),
('job-005', '+1234567894', 'New', 'DENIED', false, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day');

INSERT INTO audit_ledger (event_type, contact_id, message_body, channel, is_sandbox) VALUES
('consent_given', 'job-003', 'User consented to contact', 'SMS', false),
('message_sent', 'job-001', 'Initial contact message', 'SMS', false),
('consent_denied', 'job-005', 'User denied consent', 'SMS', false);