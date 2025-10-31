#!/bin/bash
# Comprehensive test script for Retool dashboard database
# Run this locally where fly CLI is installed

echo "🔍 Testing Fly.io Database for Retool Dashboard"
echo "================================================"

# Test 1: Connect and check job counts
echo ""
echo "1. Job Statistics:"
fly postgres connect -a n8n-db-pristine << 'EOF'
SELECT
  COUNT(*) as jobs_total,
  COUNT(*) FILTER (WHERE consent_status='PENDING') as pending,
  COUNT(*) FILTER (WHERE consent_status='GIVEN') as given,
  COUNT(*) FILTER (WHERE consent_status='DENIED') as denied
FROM jobs;
EOF

# Test 2: Check escalation queue
echo ""
echo "2. Escalation Queue (PENDING jobs with priority):"
fly postgres connect -a n8n-db-pristine << 'EOF'
SELECT id, job_id, phone, status, consent_status, created_at,
  CASE
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours' THEN 'CRITICAL'
    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '24 hours' THEN 'HIGH'
    ELSE 'NORMAL'
  END as priority
FROM jobs
WHERE consent_status = 'PENDING'
ORDER BY created_at ASC
LIMIT 10;
EOF

# Test 3: Check audit trail
echo ""
echo "3. Recent Audit Events:"
fly postgres connect -a n8n-db-pristine << 'EOF'
SELECT id, event_type, contact_id,
  LEFT(message_body, 50) as message_preview,
  channel, created_at
FROM audit_ledger
ORDER BY created_at DESC
LIMIT 5;
EOF

# Test 4: Test read-only permissions
echo ""
echo "4. Testing Read-Only Permissions (should work):"
fly postgres connect -a n8n-db-pristine -u retool_readonly << 'EOF'
SELECT COUNT(*) FROM jobs;
EOF

# Test 5: Test write permissions
echo ""
echo "5. Testing Write Permissions (should work for writer):"
fly postgres connect -a n8n-db-pristine -u retool_writer << 'EOF'
-- Test SELECT
SELECT id, consent_status FROM jobs WHERE id = (SELECT MIN(id) FROM jobs) LIMIT 1;
-- Test UPDATE (commented out to avoid actual changes)
-- UPDATE jobs SET consent_status = 'GIVEN' WHERE id = 1 AND consent_status = 'PENDING' RETURNING id;
EOF

# Test 6: Test audit immutability
echo ""
echo "6. Testing Audit Immutability (should FAIL for read-only):"
fly postgres connect -a n8n-db-pristine -u retool_readonly << 'EOF'
-- This should fail with permission denied
DELETE FROM audit_ledger WHERE id = 999999;
EOF

echo ""
echo "✅ All tests completed. Check outputs above for any errors."