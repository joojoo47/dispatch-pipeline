# Database Setup Guide for PECR/PSR Compliance Dashboard

## Current Situation

Your workspace is a dev container without a running PostgreSQL instance. The compliance dashboard expects to connect to your **external PostgreSQL database** (likely where n8n stores its data).

## Three Options to Proceed

### Option 1: Connect to Your External Database (Recommended)

If you have an external PostgreSQL database (e.g., on Fly.io, AWS RDS, or another provider):

1. **Get your database credentials:**
   - Host (e.g., `myapp.fly.dev` or `mydb.us-east-1.rds.amazonaws.com`)
   - Port (usually `5432`)
   - Database name (e.g., `n8n_dispatch`)
   - Admin username (e.g., `postgres`)
   - Admin password

2. **Run the setup script with environment variables:**

```bash
export POSTGRES_HOST="your-db-host.example.com"
export POSTGRES_PORT="5432"
export POSTGRES_ADMIN_USER="postgres"
export POSTGRES_PASSWORD="your-admin-password"

./setup_retool_dashboard.sh
```

3. **Configure Retool to connect to the same database:**
   - In Retool, go to Resources → postgres1
   - Update connection details to match your external database
   - Test the connection

---

### Option 2: Start a Local PostgreSQL Instance

If you want to test locally first:

1. **Install and start PostgreSQL:**

```bash
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib
sudo service postgresql start
```

2. **Create the database and user:**

```bash
sudo -u postgres psql <<EOF
CREATE DATABASE n8n_dispatch;
\c n8n_dispatch
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
EOF
```

3. **Run the setup script:**

```bash
export POSTGRES_HOST="localhost"
export POSTGRES_PORT="5432"
export POSTGRES_ADMIN_USER="postgres"
export POSTGRES_PASSWORD=""  # Local postgres often has no password

./setup_retool_dashboard.sh
```

---

### Option 3: Use Docker Compose (Quick Local Setup)

1. **Create `docker-compose.yml`:**

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: n8n_dispatch
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

2. **Start PostgreSQL:**

```bash
docker-compose up -d
```

3. **Run the setup script:**

```bash
export POSTGRES_HOST="localhost"
export POSTGRES_PORT="5432"
export POSTGRES_ADMIN_USER="postgres"
export POSTGRES_PASSWORD="postgres"

./setup_retool_dashboard.sh
```

---

## After Running the Setup Script

### 1. Verify Tables Exist

```bash
PGPASSWORD="your-password" psql -h your-host -U postgres -d n8n_dispatch -c "\dt"
```

You should see:
```
         List of relations
 Schema |     Name      | Type  |  Owner   
--------+---------------+-------+----------
 public | audit_ledger  | table | postgres
 public | jobs          | table | postgres
```

### 2. Check Sample Data

```bash
PGPASSWORD="your-password" psql -h your-host -U postgres -d n8n_dispatch -c "SELECT COUNT(*) FROM jobs;"
```

### 3. Verify Retool User Permissions

```bash
PGPASSWORD="your-password" psql -h your-host -U postgres -d n8n_dispatch -c "
SELECT 
  grantee, 
  table_name, 
  privilege_type 
FROM information_schema.table_privileges 
WHERE grantee = 'retool_readonly';
"
```

---

## Troubleshooting

### Error: "Cannot connect to PostgreSQL"
- Check that the database host is accessible from your dev container
- Verify credentials are correct
- Ensure the database accepts connections from your IP (check firewall/security groups)

### Error: "relation does not exist"
- The setup script didn't run successfully
- Check that you're connected to the correct database (`n8n_dispatch`)
- Verify the schema is `public` (default)

### Error: "permission denied"
- The `retool_readonly` user wasn't created or granted permissions
- Re-run the setup script with admin credentials

---

## Next Steps

Once the setup script completes successfully:

1. Reply **"go"** in the chat
2. I'll switch all Retool queries from mock data to live SQL
3. Your compliance dashboard will be fully operational with real data

---

## Quick Reference: Manual Table Creation

If the script fails, you can create tables manually:

```sql
-- Create jobs table
CREATE TABLE jobs (
    id SERIAL PRIMARY KEY,
    job_id UUID DEFAULT uuid_generate_v4(),
    phone VARCHAR(20) NOT NULL,
    status VARCHAR(50) NOT NULL,
    consent_status VARCHAR(50) DEFAULT 'PENDING',
    consent_timestamp TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create audit_ledger table (immutable)
CREATE TABLE audit_ledger (
    id SERIAL PRIMARY KEY,
    event_type VARCHAR(100) NOT NULL,
    contact_id VARCHAR(100),
    message_body TEXT,
    channel VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO jobs (phone, status, consent_status, created_at) VALUES
    ('+447700900123', 'PENDING', 'PENDING', NOW() - INTERVAL '72 hours'),
    ('+447700900456', 'PENDING', 'PENDING', NOW() - INTERVAL '36 hours'),
    ('+447700900789', 'PENDING', 'PENDING', NOW() - INTERVAL '12 hours'),
    ('+447700900111', 'COMPLETED', 'GIVEN', NOW() - INTERVAL '5 days'),
    ('+447700900222', 'COMPLETED', 'DENIED', NOW() - INTERVAL '3 days');

INSERT INTO audit_ledger (event_type, contact_id, message_body, channel) VALUES
    ('consent_request', '+447700900123', 'Initial consent request sent', 'SMS'),
    ('consent_granted', '+447700900111', 'User replied YES', 'SMS'),
    ('consent_denied', '+447700900222', 'User replied NO', 'SMS');

-- Create retool user and grant permissions
CREATE USER retool_readonly WITH PASSWORD 'SecurePass2025!@#';
GRANT CONNECT ON DATABASE n8n_dispatch TO retool_readonly;
GRANT USAGE ON SCHEMA public TO retool_readonly;
GRANT SELECT ON jobs, audit_ledger TO retool_readonly;
GRANT UPDATE (consent_status, consent_timestamp, updated_at) ON jobs TO retool_readonly;
```
