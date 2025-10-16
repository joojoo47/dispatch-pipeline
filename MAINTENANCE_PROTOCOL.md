# 🚀 N8N Dispatch Pipeline - Long-Term Maintenance Protocol

## Executive Summary
The N8N dispatch pipeline has achieved operational stability with validated GREEN zone performance. Long-term success depends on rigorous maintenance cycles to prevent software drift, security vulnerabilities, and data integrity issues.

## 📋 Maintenance Cycles Overview

### 1. System Health Cycle (Quarterly - Every 90 Days)
**Purpose**: Prevent software drift and security vulnerabilities from outdated components.

**Components to Update:**
- **N8N Application Version**: Core workflow engine updates
- **Base OS & Dependencies**: Alpine Linux packages and client libraries

**Next Scheduled**: January 15, 2026 (90 days from October 15, 2025)

#### Quarterly Update Procedure:
```bash
# 1. Update Dockerfile with latest N8N version
# Edit Dockerfile to update: npm install -g n8n@latest

# 2. Update base OS dependencies
# Edit Dockerfile to include: apk update && apk upgrade

# 3. Deploy updated container
fly deploy

# 4. Verify deployment health
curl https://n8n-dispatch.fly.dev/healthz
```

**Risk Mitigation**: Quarterly updates prevent accumulation of security vulnerabilities and ensure compatibility with evolving webhook standards.

---

### 2. Database Integrity Cycle (Monthly - Every 30 Days)
**Purpose**: Ensure PostgreSQL cluster resilience and data recoverability.

**Components to Verify:**
- **Backup Integrity**: Full pg_dump verification
- **Schema Health**: N8N table structure validation
- **Connection Stability**: Database connectivity tests

**Next Scheduled**: November 15, 2025 (30 days from October 15, 2025)

#### Monthly Database Verification Procedure:
```bash
# 1. Execute full backup of n8n-db-pristine cluster
pg_dump --host=n8n-db-pristine.internal --username=n8n_user --dbname=n8n_db --file=n8n_backup_$(date +%Y%m%d).sql

# 2. Verify backup file integrity
ls -la n8n_backup_*.sql
head -n 10 n8n_backup_$(date +%Y%m%d).sql  # Check file structure

# 3. Upload to offsite storage (S3/Google Drive)
# [Configure automated upload script]

# 4. Run schema health check
psql --host=n8n-db-pristine.internal --username=n8n_user --dbname=n8n_db -c "SELECT schemaname, tablename FROM pg_tables WHERE schemaname = 'public';"

# 5. Test N8N database connectivity
curl -H "X-N8N-API-KEY: [current_key]" https://n8n-dispatch.fly.dev/api/v1/workflows?limit=1
```

**Risk Mitigation**: Monthly backups ensure data recoverability; schema checks prevent silent corruption.

---

### 3. Security Access Cycle (Continuous Monitoring)
**Purpose**: Prevent credential compromise through systematic rotation.

**Components to Rotate:**
- **N8N API Key**: Primary authentication token
- **Database Credentials**: PostgreSQL connection secrets
- **Fly.io Access Tokens**: Infrastructure management keys

**Next API Key Rotation**: January 15, 2026 (90 days from October 15, 2025)

#### API Key Rotation Procedure:
```bash
# 1. Generate new API key in N8N UI
# Settings → API → Add API Key → Name: "api_key_2026_q1"

# 2. Update environment configuration
# Edit .env file with new key
N8N_API_KEY="new_key_here"

# 3. Update admin dashboard configuration
# Update admin_dashboard.ipynb with new key

# 4. Test new key functionality
curl -H "X-N8N-API-KEY: new_key_here" https://n8n-dispatch.fly.dev/api/v1/workflows?limit=1

# 5. Revoke old API key in N8N UI
# Settings → API → Delete old key

# 6. Update backup scripts and monitoring tools
# Ensure all automated systems use new credentials
```

**Risk Mitigation**: 90-day rotation prevents long-term credential compromise; continuous monitoring detects unauthorized access attempts.

---

## 📅 Maintenance Calendar

| Cycle | Frequency | Next Due | Responsible | Criticality |
|-------|-----------|----------|-------------|-------------|
| System Health | Quarterly | Jan 15, 2026 | DevOps | High |
| Database Integrity | Monthly | Nov 15, 2025 | DBA/DevOps | Critical |
| Security Access | 90 Days | Jan 15, 2026 | Security | Critical |

## 🔍 Monitoring & Alerting

### Automated Health Checks
- **Daily**: Concurrency watchdog monitoring
- **Weekly**: N8N service health verification
- **Monthly**: Database connection validation

### Manual Verification Points
- **Pre-Maintenance**: Run full system health assessment
- **Post-Maintenance**: Validate all workflows remain functional
- **Emergency**: Immediate action if RED zone concurrency detected

## 📊 Success Metrics

### System Health Indicators
- ✅ N8N version < 30 days old
- ✅ OS packages updated quarterly
- ✅ Zero security vulnerabilities in dependencies

### Database Integrity Indicators
- ✅ Monthly backups successful
- ✅ Schema validation passes
- ✅ Connection stability > 99.9%

### Security Indicators
- ✅ API keys rotated within 90 days
- ✅ No unauthorized access attempts
- ✅ Credentials encrypted at rest

## 🚨 Emergency Procedures

### Critical Failure Response
1. **RED Zone Concurrency**: Execute PostgreSQL migration immediately
2. **Database Corruption**: Restore from latest verified backup
3. **Security Breach**: Rotate all credentials and audit access logs

### Contact Protocol
- **System Issues**: Check admin dashboard and logs
- **Database Issues**: Verify n8n-db-pristine cluster status
- **Security Issues**: Immediate credential rotation required

---

## 📝 Maintenance Log

| Date | Cycle | Action | Status | Notes |
|------|-------|--------|--------|-------|
| 2025-10-15 | Deployment | Initial setup | ✅ Complete | GREEN zone validated |
| 2025-11-15 | Database | Monthly backup | ⏳ Scheduled | First monthly cycle |
| 2026-01-15 | System | Quarterly update | ⏳ Scheduled | N8N + OS updates |
| 2026-01-15 | Security | API key rotation | ⏳ Scheduled | 90-day rotation |

---

**Document Version**: 1.0
**Last Updated**: October 15, 2025
**Review Cycle**: Quarterly (aligns with System Health Cycle)

*Operational excellence is sustained through relentless auditing and proactive maintenance.*</content>
<parameter name="filePath">/workspaces/dispatch-pipeline/MAINTENANCE_PROTOCOL.md