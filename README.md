# dispatch-pipeline
Autonomous dispatch pipeline for fixed-price service jobs

## 🚀 Deployment Status
✅ **Production Ready** - Validated for low-to-moderate loads (≤4 concurrent workflows)

## 🏗️ Architecture

### Database: Neon PostgreSQL
- **Provider**: Managed serverless PostgreSQL on AWS (eu-west-2)
- **Purpose**: Stores jobs, audit ledger, and compliance data
- **Connection**: See `RETOOL_CONNECTION_INFO.md` for credentials
- **Migration**: Migrated from Fly.io for better reliability

### Dashboard: Retool
- **Purpose**: Web interface for PECR consent management and admin oversight
- **Resources**: 
  - `postgres_readonly` - For queries (escalation queue, stats, audit)
  - `postgres_writer` - For mutations (consent overrides)
- **Security**: Enforced read-only access for audit immutability

### Workflow Engine: n8n
- **Purpose**: Automates job creation, database queries, and Retool updates
- **Implementation**: Python simulation scripts for testing/development
- **Production**: Can be replaced with actual n8n instance using Neon credentials

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
- Execute full PostgreSQL backup on Neon
- Verify schema integrity
- Test database connectivity via Neon console

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
- Database Issues: Verify Neon project status and connection
- Security Issues: Rotate credentials immediately

## 📋 Files
- `MAINTENANCE_PROTOCOL.md` - Comprehensive maintenance procedures
- `maintenance_check.sh` - Automated health verification script
- `admin_dashboard.ipynb` - System monitoring and management
- `migrate_to_postgres.sh` - PostgreSQL migration script
- `RETOOL_CONNECTION_INFO.md` - Retool and Neon connection details
- `N8n-like trigger simulation.py` - n8n workflow simulation (Neon)
- `n8n_trigger_simulation.py` - Alternative n8n simulation script
- `base_schema.sql` - Database schema for Neon
- `DATABASE_SETUP_GUIDE.md` - Neon setup and migration guide
