# Retool PostgreSQL Connection Information

## ✅ Database Setup Complete!

Your PostgreSQL database is now running and ready for Retool.

---

## 🔌 Connection Details for Retool

Use these settings when configuring the PostgreSQL resource in Retool:

```
Resource Type: PostgreSQL
Name: postgres_compliance
Host: localhost  (or your dev container IP if Retool runs externally)
Port: 5432
Database: n8n_dispatch
Username: retool_readonly
Password: SecurePass2025!@#
SSL Mode: disable (for local development)
```

---

## 📊 Database Status

**Tables Created:**
- ✅ `jobs` - 3 test records (2 PENDING, 1 GIVEN)
- ✅ `audit_ledger` - 2 audit records

**Users Created:**
- ✅ `retool_readonly` - SELECT only on jobs, audit_ledger (for queries)
- ⚠️ You'll need a separate user with UPDATE permissions for the consent override mutation

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

### 1. Configure Retool Resource

In Retool:
1. Go to **Resources** → **Create new** → **PostgreSQL**
2. Use the connection details above
3. Click **Test connection** → **Create resource**

### 2. Update Query Resources

For each query in your dashboard:
- `escalationQueue`
- `dashboardStats`
- `auditTrail`
- `consentOverride`

Make sure the **Resource** dropdown points to `postgres_compliance`.

### 3. Create Writer User (For Mutations)

For the `consentOverride` mutation to work, you need a user with UPDATE permissions:

```bash
docker exec -i postgres-compliance psql -U postgres -d n8n_dispatch << 'EOF'
CREATE USER retool_writer WITH PASSWORD 'WriterPass2025!@#';
GRANT CONNECT ON DATABASE n8n_dispatch TO retool_writer;
GRANT USAGE ON SCHEMA public TO retool_writer;
GRANT SELECT, UPDATE (consent_status, consent_timestamp) ON jobs TO retool_writer;
GRANT INSERT ON audit_ledger TO retool_writer;
EOF
```

Then create a second PostgreSQL resource in Retool called `postgres_compliance_writer` with these credentials, and use it for the `consentOverride` query.

### 4. Test the Setup

Run each query in Retool to verify:

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

**dashboardStats:**
```sql
SELECT
  COUNT(*) FILTER (WHERE consent_status = 'PENDING') as pending,
  COUNT(*) FILTER (WHERE consent_status = 'GIVEN') as given,
  COUNT(*) FILTER (WHERE consent_status = 'DENIED') as denied,
  COUNT(*) as total
FROM jobs;
```

**auditTrail:**
```sql
SELECT id, event_type, contact_id,
  LEFT(message_body, 100) as message_preview,
  channel, created_at
FROM audit_ledger
ORDER BY created_at DESC
LIMIT 500;
```

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
