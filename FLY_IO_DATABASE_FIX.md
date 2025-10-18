# Fix Fly.io Database Schema for PECR Dashboard

## 🎯 Goal
Apply the idempotent schema migration to add:
- `audit_ledger` table
- Consent columns on `jobs` table
- Proper permissions for `retool_readonly` and `retool_writer` users

---

## 📋 Prerequisites

1. **Fly.io CLI installed** (if not, see [Installation](#install-fly-cli))
2. **Logged into Fly.io**: `fly auth login`
3. **Know your Fly.io Postgres app name**

---

## 🚀 Option 1: Via Fly.io Console (Easiest)

### Step 1: Connect to Postgres
```bash
fly postgres connect -a <your-postgres-app-name>
```

### Step 2: Copy and paste this SQL

```sql
-- Fix production schema and permissions for PECR/PSR dashboard
-- Safe to run multiple times (idempotent)

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
    GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO retool_writer;
  END IF;
END$$;

COMMIT;
```

### Step 3: Verify (optional but recommended)
```sql
-- Check tables exist
\dt public.jobs
\dt public.audit_ledger

-- Check columns
SELECT column_name FROM information_schema.columns
WHERE table_schema='public' AND table_name='jobs'
AND column_name IN ('consent_status','consent_timestamp','is_first_contact');

-- Check permissions
SELECT grantee, privilege_type
FROM information_schema.role_table_grants
WHERE table_schema='public' AND table_name IN ('jobs','audit_ledger')
  AND grantee IN ('retool_readonly','retool_writer')
ORDER BY table_name, grantee, privilege_type;
```

Expected output:
```
✅ consent_status
✅ consent_timestamp
✅ is_first_contact

✅ retool_readonly | SELECT (on both tables)
✅ retool_writer | SELECT (on jobs)
✅ retool_writer | INSERT (on audit_ledger)
```

---

## 🚀 Option 2: Via psql with Connection String

### Step 1: Get your connection string
```bash
fly postgres connect -a <your-postgres-app-name> --command "echo \$DATABASE_URL"
```

Or from Fly.io dashboard: Your app → PostgreSQL → Connection string

### Step 2: Run the migration script
```bash
psql "<your-connection-string>" < scripts/fix_prod_schema.sql
```

### Step 3: Verify
```bash
psql "<your-connection-string>" < scripts/verify_schema.sql
```

---

## 🚀 Option 3: Via Fly.io Web Console

1. Go to https://fly.io/dashboard
2. Select your Postgres app
3. Click **Console** or **SQL Editor**
4. Copy and paste the SQL from Option 1, Step 2
5. Click **Run**

---

## 🔍 Verification Checklist

After running the migration, verify in Retool:

1. **Test Connection**
   - Go to Resources → Your Postgres resource
   - Click **Test connection**
   - Should succeed without permission errors

2. **Run Test Query**
```sql
SELECT COUNT(*) as jobs_total,
       COUNT(*) FILTER (WHERE consent_status='PENDING') as pending,
       COUNT(*) FILTER (WHERE consent_status='GIVEN') as given
FROM jobs;
```
Should return results without errors.

3. **Check Audit Ledger**
```sql
SELECT COUNT(*) FROM audit_ledger;
```
Should return `0` or more (no "table doesn't exist" error).

---

## 🛠️ Troubleshooting

### Error: "permission denied for schema public"
**Solution:** You're not connected as the database owner. Use:
```bash
fly postgres connect -a <app-name> --database <db-name>
```
This connects as the superuser by default.

### Error: "role retool_readonly does not exist"
**Solution:** Create the users first:
```sql
CREATE USER retool_readonly WITH PASSWORD 'SecurePass2025!@#';
CREATE USER retool_writer WITH PASSWORD 'WriterPass2025!@#';
```
Then re-run the migration.

### Error: "relation jobs does not exist"
**Solution:** Your database is empty. Run `base_schema.sql` first:
```bash
psql "<connection-string>" < base_schema.sql
```
Then run the fix script.

### Retool still shows "priority column missing"
**This is expected!** Priority is a computed column in the query:
```sql
CASE 
  WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours' THEN 'CRITICAL'
  WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '24 hours' THEN 'HIGH'
  ELSE 'NORMAL'
END as priority
```
Your schema verifier should not expect a physical `priority` column.

---

## 📦 Install Fly CLI

### macOS/Linux
```bash
curl -L https://fly.io/install.sh | sh
```

### Windows (PowerShell)
```powershell
iwr https://fly.io/install.ps1 -useb | iex
```

### Via Homebrew (macOS)
```bash
brew install flyctl
```

After install:
```bash
fly auth login
```

---

## 🎯 Next Steps After Fix

1. **Re-test Retool connection** - Should pass schema verification
2. **Update all Retool queries** to use the live Postgres resource
3. **Test consent override** - Grant consent on a pending job
4. **Verify audit immutability** - Try to UPDATE audit_ledger (should fail)

---

## 📝 Notes

- ✅ This script is **idempotent** - safe to run multiple times
- ✅ Tested locally against Docker Postgres
- ✅ All changes wrapped in a transaction (rolls back on error)
- ⚠️ Requires superuser/owner privileges on Fly.io database
- 💾 The fix is committed in: `scripts/fix_prod_schema.sql`

---

**Questions?** Check the repo files:
- `scripts/fix_prod_schema.sql` - The migration script
- `scripts/verify_schema.sql` - Verification queries
- `RETOOL_CONNECTION_INFO.md` - Retool setup guide
- `DATABASE_SETUP_GUIDE.md` - Detailed database setup
