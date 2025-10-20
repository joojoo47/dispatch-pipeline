# Retool PostgreSQL Connection Information

## ✅ Database Setup Complete!

Your PostgreSQL database is now running on Neon and ready for Retool.

---

## 🔌 Connection Details for Retool

Use these settings when configuring the PostgreSQL resource in Retool:

```
Resource Type: PostgreSQL
Name: postgres_readonly
Host: ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech
Port: 5432
Database: n8n_dispatch
Username: retool_readonly
Password: npg_1WF4oLEXJahs
SSL Mode: require
```

For the writer resource:
```
Resource Type: PostgreSQL
Name: postgres_writer
Host: ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech
Port: 5432
Database: n8n_dispatch
Username: retool_writer
Password: npg_aT13fOEwpdhM
SSL Mode: require
```

---

## 📊 Database Status

**Tables Created:**
- ✅ `jobs` - 5 test records (3 PENDING, 1 GIVEN, 1 DENIED)
- ✅ `audit_ledger` - 3 audit records

**Users Created:**
- ✅ `retool_readonly` - SELECT only on jobs, audit_ledger (for queries)
- ✅ `retool_writer` - SELECT, UPDATE on jobs; INSERT on audit_ledger (for mutations)

---

## 🔐 Security Configuration

**retool_readonly permissions:**
```sql
SELECT on jobs ✅
SELECT on audit_ledger ✅
UPDATE on jobs ❌ (intentionally blocked)
INSERT on audit_ledger ❌ (intentionally blocked)
```

This enforces immutability for the audit trail and prevents unauthorized modifications.

---

## 🚀 Next Steps

### 1. Update Retool Resources
Update your PostgreSQL resources in Retool with the Neon details above.

### 2. Test Queries
Assign queries to resources:
- `escalationQueue`, `dashboardStats`, `auditTrail` → `postgres_readonly`
- `consentOverride` → `postgres_writer`

### 3. Verify Setup
Run the escalation queue query to ensure data loads.

### 4. Test Consent Override
Follow the compliance verification tests below.

### 5. Clean Up Fly.io (Optional)
If not already done, delete the old Fly.io app `n8n-db-pristine` to avoid charges:
- Run `fly apps destroy n8n-db-pristine` on your local machine.

**escalationQueue:**
```sql
SELECT id, phone, status, consent_status, created_at,
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

Should return results without errors.

---

## 🧪 Compliance Verification Tests

Once all queries are working:

### Test 1: PECR Consent Override
1. In the escalation queue, select a PENDING job
2. Click "Grant Consent"
3. Verify:
   - Job's `consent_status` changes to 'GIVEN'
   - Job disappears from escalation queue
   - Statistics update (pending -1, given +1)
   - New audit_ledger entry created

### Test 2: Audit Immutability
1. Try to create a query that updates audit_ledger:
   ```sql
   UPDATE audit_ledger SET event_type = 'TEST' WHERE id = 1;
   ```
2. Expected result: `ERROR: permission denied for table audit_ledger`
3. This confirms retool_readonly enforcement ✅

---

## 🛠️ Useful Commands

**View all jobs (via Neon):**
```bash
psql "postgresql://neondb_owner:npg_4vSDZqJiOaC1@ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech/n8n_dispatch?sslmode=require&options=endpoint%3Dep-soft-wave-ab54c4oo-pooler" -c "SELECT * FROM jobs;"
```

**View audit trail (via Neon):**
```bash
psql "postgresql://neondb_owner:npg_4vSDZqJiOaC1@ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech/n8n_dispatch?sslmode=require&options=endpoint%3Dep-soft-wave-ab54c4oo-pooler" -c "SELECT * FROM audit_ledger ORDER BY created_at DESC;"
```

**Connect to Neon for manual queries:**
```bash
psql "postgresql://neondb_owner:npg_4vSDZqJiOaC1@ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech/n8n_dispatch?sslmode=require&options=endpoint%3Dep-soft-wave-ab54c4oo-pooler"
```

---

## 📝 Notes

- Database is running on Neon (managed PostgreSQL) in AWS Europe West 2.
- Data persists automatically with Neon's backup and restore features.
- For production scaling, monitor compute usage in Neon dashboard.
- Migrated from Fly.io due to instability; Neon provides better reliability.

---

**You're now ready to connect Retool and run your compliance verification tests!** 🎉
