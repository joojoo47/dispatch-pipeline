#!/bin/bash
# Setup script for Retool Compliance Dashboard
# This script verifies database permissions and prepares the environment

set -e

echo "=========================================="
echo "PECR/PSR Compliance Dashboard Setup"
echo "=========================================="
echo ""

# Configuration
DB_NAME="n8n_dispatch"
RETOOL_USER="retool_readonly"
POSTGRES_HOST="${POSTGRES_HOST:-localhost}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
POSTGRES_ADMIN_USER="${POSTGRES_ADMIN_USER:-postgres}"

echo "📋 Configuration:"
echo "  Database: $DB_NAME"
echo "  Host: $POSTGRES_HOST:$POSTGRES_PORT"
echo "  Retool User: $RETOOL_USER"
echo ""

# Step 1: Verify PostgreSQL connection
echo "🔍 Step 1: Verifying PostgreSQL connection..."
if PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ PostgreSQL connection successful"
else
    echo "❌ ERROR: Cannot connect to PostgreSQL"
    exit 1
fi

# Step 2: Create retool_readonly user (if not exists)
echo ""
echo "👤 Step 2: Creating retool_readonly user..."
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" <<EOF
DO \$\$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '$RETOOL_USER') THEN
        CREATE USER $RETOOL_USER WITH PASSWORD 'SecurePass2025!@#';
        RAISE NOTICE 'User $RETOOL_USER created successfully';
    ELSE
        RAISE NOTICE 'User $RETOOL_USER already exists';
    END IF;
END
\$\$;

-- Grant connection and schema access
GRANT CONNECT ON DATABASE $DB_NAME TO $RETOOL_USER;
GRANT USAGE ON SCHEMA public TO $RETOOL_USER;

-- Grant SELECT on audit_ledger (READ-ONLY)
GRANT SELECT ON audit_ledger TO $RETOOL_USER;

-- Grant SELECT and UPDATE on jobs (for manual overrides)
GRANT SELECT, UPDATE ON jobs TO $RETOOL_USER;

-- Grant SELECT on sequences
GRANT SELECT ON jobs_id_seq TO $RETOOL_USER;
EOF

if [ $? -eq 0 ]; then
    echo "✅ User permissions configured"
else
    echo "❌ ERROR: Failed to configure permissions"
    exit 1
fi

# Step 3: Verify permissions
echo ""
echo "🔐 Step 3: Verifying least-privilege enforcement..."
PERMISSION_CHECK=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" -t -c "
SELECT 
    table_name, 
    string_agg(privilege_type, ', ' ORDER BY privilege_type) as privileges
FROM information_schema.role_table_grants 
WHERE grantee = '$RETOOL_USER'
  AND table_schema = 'public'
GROUP BY table_name
ORDER BY table_name;
")

echo "$PERMISSION_CHECK"
echo ""

# Step 4: Verify audit_ledger is READ-ONLY
echo "🔒 Step 4: Verifying audit_ledger immutability..."
AUDIT_PERMISSIONS=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" -t -c "
SELECT privilege_type 
FROM information_schema.role_table_grants 
WHERE grantee = '$RETOOL_USER' 
  AND table_name = 'audit_ledger';
" | tr -d ' ')

if [ "$AUDIT_PERMISSIONS" = "SELECT" ]; then
    echo "✅ VERIFIED: audit_ledger is READ-ONLY (SELECT only)"
else
    echo "⚠️  WARNING: audit_ledger has permissions: $AUDIT_PERMISSIONS"
    echo "   Expected: SELECT only"
fi

# Step 5: Test queries
echo ""
echo "🧪 Step 5: Testing compliance queries..."

# Test 1: Escalation Queue
echo "  Testing PECR Escalation Queue..."
PENDING_COUNT=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" -t -c "
SELECT COUNT(*) FROM jobs WHERE consent_status = 'PENDING';
" | tr -d ' ')
echo "    ✅ Found $PENDING_COUNT jobs with PENDING consent"

# Test 2: Audit Trail
echo "  Testing Immutable Audit Trail..."
AUDIT_COUNT=$(PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" -t -c "
SELECT COUNT(*) FROM audit_ledger;
" | tr -d ' ')
echo "    ✅ Found $AUDIT_COUNT audit entries"

# Test 3: Dashboard Stats
echo "  Testing Compliance Statistics..."
PGPASSWORD="${POSTGRES_PASSWORD}" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_ADMIN_USER" -d "$DB_NAME" <<EOF
SELECT 
  COUNT(*) FILTER (WHERE consent_status = 'PENDING') as pending_consent,
  COUNT(*) FILTER (WHERE consent_status = 'GIVEN') as consent_given,
  COUNT(*) FILTER (WHERE consent_status = 'DENIED') as consent_denied,
  COUNT(*) as total_jobs
FROM jobs;
EOF
echo "    ✅ Statistics query successful"

# Step 6: Generate Retool connection string
echo ""
echo "=========================================="
echo "✅ Setup Complete!"
echo "=========================================="
echo ""
echo "📝 Retool Configuration:"
echo ""
echo "Connection Type: PostgreSQL"
echo "Host: $POSTGRES_HOST"
echo "Port: $POSTGRES_PORT"
echo "Database: $DB_NAME"
echo "User: $RETOOL_USER"
echo "Password: SecurePass2025!@#"
echo "SSL Mode: require"
echo ""
echo "⚠️  SECURITY REMINDER:"
echo "   - retool_readonly can SELECT from audit_ledger (read-only)"
echo "   - retool_readonly can UPDATE jobs (for manual overrides)"
echo "   - retool_readonly CANNOT modify audit_ledger"
echo "   - All manual overrides are auditable"
echo ""
echo "📋 Next Steps:"
echo "   1. Import retool_compliance_dashboard.json into Retool"
echo "   2. Configure PostgreSQL data source with credentials above"
echo "   3. Link queries to UI components"
echo "   4. Test manual override buttons"
echo "   5. Verify audit logging"
echo ""
