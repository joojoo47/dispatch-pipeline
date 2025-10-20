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

### 1. Create Users on Fly.io Database
Since the database is on Fly.io, you need to create the users there.

**Connect to Fly.io Postgres:**
```bash
fly postgres connect -a n8n-db-pristine
```

**Run this SQL to create users:**
```sql
CREATE USER retool_readonly WITH PASSWORD 'SecurePass2025!@#';
CREATE USER retool_writer WITH PASSWORD 'WriterPass2025!@#';
```

### 2. Run Schema Migration on Fly.io
Apply the schema fix from `FLY_IO_DATABASE_FIX.md` to add tables and permissions.

### 3. Configure Retool Resources
In Retool, create two PostgreSQL resources using the details above.

### 4. Update Query Resources
For each query in your dashboard:
- `escalationQueue`, `dashboardStats`, `auditTrail` → `postgres_readonly`
- `consentOverride` → `postgres_writer`

### 5. Test the Setup
Run each query in Retool to verify.

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

**View all jobs:**
```bash
docker exec -i postgres-compliance psql -U postgres -d n8n_dispatch -c "SELECT * FROM jobs;"
```

**View audit trail:**
```bash
docker exec -i postgres-compliance psql -U postgres -d n8n_dispatch -c "SELECT * FROM audit_ledger ORDER BY created_at DESC;"
```

**Stop PostgreSQL:**
```bash
docker stop postgres-compliance
```

**Start PostgreSQL:**
```bash
docker start postgres-compliance
```

**Remove PostgreSQL (clean slate):**
```bash
docker rm -f postgres-compliance
```

---

## 📝 Notes

- Database is running locally in Docker on port 5432
- Data persists as long as the container exists
- If you remove the container, all data will be lost (use volumes for persistence)
- For production, use a managed PostgreSQL service (AWS RDS, Fly.io Postgres, etc.)

---

**You're now ready to connect Retool and run your compliance verification tests!** 🎉
