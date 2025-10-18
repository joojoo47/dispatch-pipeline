# 📁 Dashboard Files Reference

## 🚦 Start Here

**For quick setup:** Read [`QUICK_START.md`](./QUICK_START.md)  
**For detailed guide:** Read [`RETOOL_IMPORT_INSTRUCTIONS.md`](./RETOOL_IMPORT_INSTRUCTIONS.md)

---

## 📋 File Guide

| File | Purpose | Use When |
|:---|:---|:---|
| **`QUICK_START.md`** | 5-minute setup guide | First-time setup ⭐ |
| **`RETOOL_IMPORT_INSTRUCTIONS.md`** | Detailed instructions | Need more context |
| **`retool_dashboard_specification.json`** | Complete spec (all queries) | Reference for SQL |
| **`retool_import_minimal.json`** | Minimal Retool import | Import as template |
| **`setup_retool_dashboard.sh`** | PostgreSQL setup script | Database prep |
| **`retool_admin_dashboard.json`** | Original export attempt | Historical reference |

---

## 🎯 What to Use

### Option 1: Manual Setup (Recommended)
```bash
# 1. Run database setup
./setup_retool_dashboard.sh

# 2. Follow QUICK_START.md
#    - Add PostgreSQL resource
#    - Create app
#    - Copy-paste queries from guide
#    - Build UI components
```

### Option 2: Import Template
```bash
# 1. Run database setup
./setup_retool_dashboard.sh

# 2. Import retool_import_minimal.json in Retool
# 3. Add queries manually from QUICK_START.md
# 4. Build UI components
```

---

## 🔍 Why the Import Error Happened

### The Problem
```json
// This file is a SPECIFICATION (human-readable)
{
  "dashboard_name": "PECR/PSR Compliance Dashboard",
  "queries": {
    "escalation_queue": {
      "sql": "SELECT ...",
      ...
    }
  }
}
```

### What Retool Expects
```json
// Retool needs Transit JSON encoding (machine format)
{
  "uuid": "...",
  "page": {
    "data": {
      "appState": "[\"~#iR\",[\"^ \",\"n\",\"appTemplate\"..."
    }
  }
}
```

The `appState` is encoded in **Transit JSON** format - a Clojure data serialization format that Retool uses internally. It's not meant to be hand-crafted.

---

## ✅ Solution

**Manual setup is faster and more reliable** than trying to craft a valid Retool export file.

Follow [`QUICK_START.md`](./QUICK_START.md) - takes ~5 minutes total.

---

## 🛡️ Security Architecture

```
┌─────────────────────────────────────────┐
│         Retool Dashboard                │
│   (retool_readonly credentials)         │
└──────────────┬──────────────────────────┘
               │
               ├─ SELECT ────────┐
               │                 ▼
               │         ┌──────────────┐
               │         │ audit_ledger │  READ-ONLY
               │         │ (immutable)  │  ✅ Cannot UPDATE
               │         └──────────────┘
               │
               ├─ SELECT ────────┐
               │                 ▼
               ├─ UPDATE ────► ┌──────────────┐
               │               │     jobs     │  LIMITED WRITE
               │               │ (overrides)  │  ✅ Can UPDATE
               │               └──────────────┘  ❌ Cannot DELETE
               │
               └─ BLOCKED ────► INSERT, DELETE, DROP
                                ❌ No admin access
```

### Permissions Enforced
- ✅ `SELECT` on `audit_ledger` (compliance proof)
- ✅ `SELECT, UPDATE` on `jobs` (manual overrides)
- ❌ No `UPDATE` on `audit_ledger` (immutability)
- ❌ No `DELETE` anywhere (data protection)
- ❌ No `INSERT` (prevents data injection)

---

## 📊 Dashboard Components

### 1. Statistics Panel
- **Pending Consent** - PECR compliance queue
- **Consent Given** - Processed communications
- **Consent Denied** - Blocked contacts
- **Critical Escalations** - >48h pending

### 2. Escalation Queue Table
- Shows jobs awaiting consent
- "Grant Consent" button (with confirmation)
- Color-coded priority (CRITICAL/HIGH/NORMAL)

### 3. Audit Trail Table
- Immutable event log
- Read-only (retool_readonly cannot modify)
- Full PECR/PSR compliance proof

---

## 🔧 Troubleshooting

### Import Error
**Error:** `Cannot read properties of undefined (reading 'data')`  
**Fix:** Don't import `retool_dashboard_specification.json` - it's a spec, not an export. Follow `QUICK_START.md` instead.

### Permission Denied
**Error:** `permission denied for table audit_ledger`  
**Status:** ✅ **This is correct!** The table should be read-only.

### Connection Refused
**Error:** `ECONNREFUSED` or timeout  
**Fix:** 
1. Check PostgreSQL host/port in Retool resource config
2. Verify `retool_readonly` user exists: `./setup_retool_dashboard.sh`
3. Check SSL mode is set to `require`

---

## 📚 Related Documentation

- **PECR Compliance:** `PECR_CONSENT_DEPLOYMENT.md`
- **Database Schema:** `base_schema.sql`
- **Database Migration:** `database_migration_pe_cr_consent.sql`
- **Maintenance Protocol:** `MAINTENANCE_PROTOCOL.md`

---

## 🎯 Regulatory Compliance

| Regulation | Implementation | File Reference |
|:---|:---|:---|
| **PECR Reg. 22** | Escalation queue + consent lock | `retool_dashboard_specification.json` → `escalation_queue` |
| **PSR 2017** | Manual payment confirmation | `retool_dashboard_specification.json` → `payment_confirmation` |
| **ICO Accountability** | Immutable audit trail | `create_retool_user.sql` → READ-ONLY audit_ledger |
| **Least Privilege** | Database-level enforcement | `setup_retool_dashboard.sh` → Permission verification |

---

**Need help?** Check [`QUICK_START.md`](./QUICK_START.md) first, then [`RETOOL_IMPORT_INSTRUCTIONS.md`](./RETOOL_IMPORT_INSTRUCTIONS.md).
