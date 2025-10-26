-- Create n8n database user with full permissions
-- Run this in Neon SQL editor

-- Create n8n user
CREATE USER n8n_user WITH PASSWORD 'npg_n8n_secure_password_2025';

-- Grant permissions on database
GRANT ALL PRIVILEGES ON DATABASE n8n_dispatch TO n8n_user;

-- Grant permissions on schema
GRANT ALL ON SCHEMA public TO n8n_user;

-- Grant permissions on all existing tables
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8n_user;

-- Grant permissions on all future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO n8n_user;

-- Grant permissions on sequences
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO n8n_user;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO n8n_user;