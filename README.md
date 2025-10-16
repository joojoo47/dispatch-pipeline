# dispatch-pipeline
Autonomous dispatch pipeline for fixed-price service jobs

## 🚀 Deployment Status
✅ **Production Ready** - Validated for low-to-moderate loads (≤4 concurrent workflows)

## 🛡️ Maintenance Protocols

### Automated Maintenance
Run the maintenance health check script monthly:
```bash
./maintenance_check.sh
```

### Manual Maintenance Cycles

#### 1. System Health (Quarterly - Every 90 Days)
- Update N8N version in Dockerfile
- Update base OS dependencies
- Deploy with `fly deploy`

#### 2. Database Integrity (Monthly - Every 30 Days)
- Execute full PostgreSQL backup
- Verify schema integrity
- Test database connectivity

#### 3. Security Access (90-Day Rotation)
- Rotate N8N API keys
- Update database credentials
- Validate access controls

### Risk Management
- 🟢 **GREEN Zone**: ≤4 concurrent workflows (safe operations)
- 🟡 **YELLOW Zone**: 5-7 concurrent workflows (schedule PostgreSQL migration)
- 🔴 **RED Zone**: 8+ concurrent workflows (execute immediate PostgreSQL migration)

### Emergency Contacts
- System Issues: Check admin dashboard and logs
- Database Issues: Verify n8n-db-pristine cluster status
- Security Issues: Rotate credentials immediately

## 📋 Files
- `MAINTENANCE_PROTOCOL.md` - Comprehensive maintenance procedures
- `maintenance_check.sh` - Automated health verification script
- `admin_dashboard.ipynb` - System monitoring and management
- `migrate_to_postgres.sh` - PostgreSQL migration script
