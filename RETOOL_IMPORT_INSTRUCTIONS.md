# Retool Compliance Dashboard - Import Instructions

## ⚠️ IMPORTANT: The JSON file is a SPECIFICATION, not a direct import

The `retool_compliance_dashboard.json` file is a **specification document** that describes the dashboard structure. Retool requires a specific internal format that cannot be easily hand-crafted.

## 📋 How to Build the Dashboard in Retool

### Option 1: Manual Setup (Recommended for new dashboards)

#### Step 1: Create PostgreSQL Data Source
1. Go to Retool → Resources → Add Resource
2. Select **PostgreSQL**
3. Configure connection:
   ```
   Host: <your-postgres-host>
   Port: 5432
   Database: n8n_dispatch
   User: retool_readonly
   Password: SecurePass2025!@#
   SSL Mode: require
   ```
4. Test connection and save as `postgres_compliance`

#### Step 2: Create New App
1. Retool → Apps → Create New → Blank App
2. Name it: **PECR/PSR Compliance Dashboard**

#### Step 3: Add Queries (from the specification file)

Copy these queries from `retool_compliance_dashboard.json`:

##### Query 1: escalation_queue
```sql
SELECT 
  id,
  job_id,
  phone,
  status,
  consent_status,
  is_first_contact,
  created_at,
  consent_timestamp,
  CASE 
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours' THEN 'CRITICAL'
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '24 hours' THEN 'HIGH'
    ELSE 'NORMAL'
  END as escalation_priority
FROM jobs
WHERE consent_status = 'PENDING'
ORDER BY created_at ASC
LIMIT 100;
```

##### Query 2: audit_trail
```sql
SELECT 
  id,
  event_type,
  contact_id,
  LEFT(message_body, 100) as message_preview,
  channel,
  is_sandbox,
  created_at
FROM audit_ledger
ORDER BY created_at DESC
LIMIT 500;
```

##### Query 3: consent_override
```sql
UPDATE jobs
SET 
  consent_status = 'GIVEN',
  consent_timestamp = NOW()
WHERE id = {{ selected_job_id.value }}
RETURNING id, job_id, phone, consent_status, consent_timestamp;
```

##### Query 4: dashboard_stats
```sql
SELECT 
  COUNT(*) FILTER (WHERE consent_status = 'PENDING') as pending_consent,
  COUNT(*) FILTER (WHERE consent_status = 'GIVEN') as consent_given,
  COUNT(*) FILTER (WHERE consent_status = 'DENIED') as consent_denied,
  COUNT(*) FILTER (WHERE consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours') as critical_escalations,
  COUNT(*) as total_jobs
FROM jobs;
```

#### Step 4: Build UI Components

1. **Statistics Cards (Top)**
   - Add 4 **Statistic** components
   - Bind to `{{ dashboard_stats.data.pending_consent }}`, etc.
   - Set colors: orange, green, red, red

2. **Escalation Table**
   - Add **Table** component
   - Data source: `{{ escalation_queue.data }}`
   - Add action buttons:
     - "✅ Grant Consent" → triggers `consent_override`
     - "❌ Deny Consent" → triggers denial query

3. **Audit Trail Table**
   - Add **Table** component (read-only)
   - Data source: `{{ audit_trail.data }}`

#### Step 5: Configure Auto-Refresh
- Set queries to run on page load
- Enable auto-refresh (30s for escalation_queue, 60s for audit_trail)

---

### Option 2: Use Existing Dashboard Export (if available)

If you have access to an existing Retool dashboard:

1. Go to the dashboard in Retool
2. Click **⋯** (menu) → **Export**
3. Save as `retool_export.json`
4. Use that file for importing to other Retool instances

---

### Option 3: Import from Retool Template (if we had one)

Retool import requires this exact structure:
```json
{
  "uuid": "<generated-uuid>",
  "page": {
    "id": <numeric-id>,
    "data": {
      "appState": "<transit-encoded-state>",
      ...
    }
  }
}
```

The `appState` is a **Transit JSON** encoded string (not regular JSON) that Retool uses internally.

---

## 🔧 Quick Start Script

Run this to verify your PostgreSQL connection:

```bash
# Run the setup script
./setup_retool_dashboard.sh

# This will verify:
# - retool_readonly user exists
# - Permissions are correct
# - Queries work
```

---

## 📝 Reference: SQL Queries

All SQL queries are documented in `retool_compliance_dashboard.json` under the `queries` section. Use these as the source of truth when building your dashboard.

---

## 🛡️ Security Verification

After building the dashboard, verify security:

```sql
-- Verify retool_readonly permissions (should only show SELECT)
SELECT privilege_type 
FROM information_schema.role_table_grants 
WHERE grantee = 'retool_readonly' 
  AND table_name = 'audit_ledger';

-- Test that UPDATE is blocked (should fail)
UPDATE audit_ledger SET event_type = 'test' WHERE id = 1;
```

Expected result: `ERROR: permission denied for table audit_ledger`

---

## 📚 Additional Resources

- Retool Docs: https://docs.retool.com/docs/postgresql
- PECR Compliance: See `PECR_CONSENT_DEPLOYMENT.md`
- Database Schema: See `base_schema.sql`

---

## ❓ Troubleshooting

### "Cannot read properties of undefined (reading 'data')"
- This means you're trying to import a specification file, not a Retool export
- Solution: Build the dashboard manually using the queries from the spec

### "Permission denied for table audit_ledger"
- This is EXPECTED behavior when trying to UPDATE
- It confirms the security model is working correctly

### "Connection refused"
- Check PostgreSQL host/port in connection settings
- Verify `retool_readonly` user exists (run `setup_retool_dashboard.sh`)
