# 🚀 PECR/PSR Compliance Dashboard - Quick Start

## ⚠️ Import Error Fix

**Error:** `Cannot read properties of undefined (reading 'data')`  
**Cause:** The JSON file was a specification document, not a Retool export  
**Solution:** Build dashboard manually (5 minutes) or import minimal template

---

## Option 1: Build Manually (Recommended) ⭐

### Step 1: Add PostgreSQL Resource (1 minute)

1. Open Retool
2. Go to **Resources** → **Create new** → **PostgreSQL**
3. Fill in:
   ```
   Name: postgres_compliance
   Host: <your-postgres-host>
   Port: 5432
   Database: n8n_dispatch
   Username: retool_readonly
   Password: SecurePass2025!@#
   SSL Mode: require
   ```
4. Click **Test connection** → **Create resource**

### Step 2: Create App (1 minute)

1. Go to **Apps** → **Create new** → **From scratch**
2. Name: **PECR/PSR Compliance Dashboard**
3. Click **Create app**

### Step 3: Add Queries (2 minutes)

Click **+ New** → **Query** for each of these:

#### Query 1: `escalation_queue`
```sql
SELECT id, job_id, phone, status, consent_status, created_at,
  CASE 
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours' THEN 'CRITICAL'
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '24 hours' THEN 'HIGH'
    ELSE 'NORMAL'
  END as priority
FROM jobs
WHERE consent_status = 'PENDING'
ORDER BY created_at ASC
LIMIT 100;
```
✅ Enable **Run query on page load**

#### Query 2: `dashboard_stats`
```sql
SELECT 
  COUNT(*) FILTER (WHERE consent_status = 'PENDING') as pending,
  COUNT(*) FILTER (WHERE consent_status = 'GIVEN') as given,
  COUNT(*) FILTER (WHERE consent_status = 'DENIED') as denied,
  COUNT(*) as total
FROM jobs;
```
✅ Enable **Run query on page load**

#### Query 3: `audit_trail`
```sql
SELECT id, event_type, contact_id, 
  LEFT(message_body, 100) as message_preview,
  channel, created_at
FROM audit_ledger
ORDER BY created_at DESC
LIMIT 500;
```
✅ Enable **Run query on page load**

#### Query 4: `consent_override`
```sql
UPDATE jobs
SET consent_status = 'GIVEN', consent_timestamp = NOW()
WHERE id = {{ table1.selectedRow.data.id }}
RETURNING id, job_id, consent_status;
```
⚠️ **Manual trigger only** (no auto-run)

### Step 4: Build UI (1 minute)

Drag these components from the left panel:

1. **Statistic** (x4) - for dashboard stats
   - Bind to: `{{ dashboard_stats.data.pending }}`, `.given`, `.denied`, `.total`
   - Labels: "⏳ Pending", "✅ Given", "❌ Denied", "📊 Total"

2. **Table** - for escalation queue
   - Data: `{{ escalation_queue.data }}`
   - Add button column:
     - Label: "✅ Grant Consent"
     - Action: Run query `consent_override`
     - Confirm: ✅ Enable confirmation

3. **Table** - for audit trail
   - Data: `{{ audit_trail.data }}`
   - Disable editing

### Step 5: Save & Test ✅

1. Click **Preview** (top right)
2. Test:
   - ✅ Statistics cards show numbers
   - ✅ Escalation table shows pending jobs
   - ✅ "Grant Consent" button works (with confirmation)
   - ✅ Audit trail is read-only

**Done! 🎉 Your dashboard is live.**

---

## Option 2: Import Minimal Template (Advanced)

If you want to start with a blank template:

1. Download `retool_import_minimal.json`
2. In Retool: **Apps** → **Import app**
3. Upload the JSON file
4. Follow **Step 3** above to add queries
5. Follow **Step 4** above to build UI

---

## 🔐 Security Verification

Run this in PostgreSQL to verify least-privilege:

```sql
-- Should return only 'SELECT' for audit_ledger
SELECT privilege_type FROM information_schema.role_table_grants 
WHERE grantee = 'retool_readonly' AND table_name = 'audit_ledger';

-- Should FAIL with "permission denied" (this is correct!)
UPDATE audit_ledger SET event_type = 'test' WHERE id = 1;
```

✅ If UPDATE fails → Security is working correctly  
❌ If UPDATE succeeds → **SECURITY ISSUE** - retool_readonly has too many permissions

---

## 📚 Full Documentation

- **Setup Script:** `./setup_retool_dashboard.sh`
- **All Queries:** `retool_dashboard_specification.json`
- **Detailed Guide:** `RETOOL_IMPORT_INSTRUCTIONS.md`
- **Database Schema:** `base_schema.sql`

---

## ❓ Troubleshooting

| Error | Solution |
|:---|:---|
| "Cannot read properties of undefined" | Don't import the spec file - build manually |
| "Connection refused" | Check PostgreSQL host/port |
| "Permission denied for audit_ledger" | **This is correct!** Table should be read-only |
| "retool_readonly does not exist" | Run `./setup_retool_dashboard.sh` |

---

## 🎯 What This Dashboard Does

✅ **PECR Reg. 22 Compliance**
- Shows jobs awaiting consent (prevents accidental violations)
- Manual override for phone consent confirmations

✅ **PSR 2017 Compliance**
- Manual payment confirmation for bank transfers/cash
- Auditable record of all payment status changes

✅ **ICO Accountability**
- Immutable audit trail (retool_readonly cannot modify)
- Demonstrates due diligence in consent management

---

**Questions?** Check `RETOOL_IMPORT_INSTRUCTIONS.md` for detailed explanations.
