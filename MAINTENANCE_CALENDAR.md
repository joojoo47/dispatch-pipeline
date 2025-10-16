# 📅 N8N Dispatch Pipeline - Maintenance Calendar

## 2025-2026 Maintenance Schedule

### October 2025
- ✅ **Oct 15**: Deployment completed, GREEN zone validated
- ⏳ **Nov 15**: Database Integrity Cycle (Monthly backup & health check)

### November 2025
- ⏳ **Nov 15**: Database Integrity Cycle
- ⏳ **Dec 15**: Database Integrity Cycle

### December 2025
- ⏳ **Dec 15**: Database Integrity Cycle

### January 2026
- ⏳ **Jan 15**: System Health Cycle (Quarterly N8N + OS updates)
- ⏳ **Jan 15**: Security Access Cycle (API key rotation)
- ⏳ **Jan 15**: Database Integrity Cycle

### February 2026
- ⏳ **Feb 15**: Database Integrity Cycle

### March 2026
- ⏳ **Mar 15**: Database Integrity Cycle

### April 2026
- ⏳ **Apr 15**: System Health Cycle (Quarterly updates)
- ⏳ **Apr 15**: Database Integrity Cycle

## Maintenance Checklist Template

### Pre-Maintenance
- [ ] Run `./maintenance_check.sh` for health assessment
- [ ] Verify concurrency watchdog shows GREEN status
- [ ] Backup current configuration files
- [ ] Document current versions and settings

### System Health Cycle (Quarterly)
- [ ] Update N8N version in Dockerfile (`npm install -g n8n@latest`)
- [ ] Update Alpine packages (`apk update && apk upgrade`)
- [ ] Test deployment locally if possible
- [ ] Execute `fly deploy`
- [ ] Verify all workflows remain functional
- [ ] Update maintenance log

### Database Integrity Cycle (Monthly)
- [ ] Execute `pg_dump` of n8n-db-pristine cluster
- [ ] Verify backup file integrity and size
- [ ] Upload backup to offsite storage
- [ ] Run schema validation queries
- [ ] Test N8N database connectivity
- [ ] Update backup inventory log

### Security Access Cycle (90 Days)
- [ ] Generate new API key in N8N UI
- [ ] Update .env file with new key
- [ ] Update admin_dashboard.ipynb configuration
- [ ] Test new key functionality
- [ ] Revoke old API key
- [ ] Update all automated scripts and tools
- [ ] Verify no service interruptions

### Post-Maintenance
- [ ] Run `./maintenance_check.sh` to validate changes
- [ ] Update maintenance log with results
- [ ] Schedule next maintenance cycle
- [ ] Document any issues encountered and resolutions

## Emergency Procedures

### RED Zone Response (8+ concurrent workflows)
1. Execute PostgreSQL migration immediately
2. Run full system health assessment
3. Document incident and resolution
4. Review and update concurrency thresholds if needed

### System Failure Response
1. Check admin dashboard for error details
2. Review recent maintenance logs
3. Verify database connectivity
4. Execute rollback procedures if deployment-related

### Security Incident Response
1. Rotate all affected credentials immediately
2. Audit access logs for unauthorized activity
3. Update security monitoring rules
4. Document incident for future prevention

---

*This calendar ensures operational excellence through proactive maintenance and risk management.*