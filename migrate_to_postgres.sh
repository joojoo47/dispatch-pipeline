#!/bin/bash
# PostgreSQL Migration Script for N8N
# Execute when Concurrency Watchdog hits YELLOW or RED threshold

set -e  # Exit on any error

echo "🛑 STEP 1: Halting N8N Application"
echo "Stopping N8N machine to prevent data corruption during migration..."
MACHINE_ID=$(fly machine list -a n8n-clean-deploy -j | jq -r '.[0].id')
echo "Machine ID: $MACHINE_ID"
fly machine stop $MACHINE_ID

echo "✅ Verifying machine is stopped..."
fly status --app n8n-clean-deploy

echo ""
echo "🗃️ STEP 2: Data Migration"
echo "Launching temporary migration machine..."
fly machine run \
    n8nio/n8n:latest \
    --app n8n-clean-deploy \
    --region lhr \
    --vm-memory 1024 \
    --rm \
    --entrypoint n8n \
    -- \
    migration:run

echo ""
echo "🚀 STEP 3: Restarting Production Machine"
echo "Starting N8N with PostgreSQL persistence..."
fly machine start $MACHINE_ID

echo "⏳ Waiting for application to start..."
sleep 10

echo ""
echo "✅ STEP 4: Verification"
echo "Checking application logs for PostgreSQL connection..."
fly logs --app n8n-clean-deploy | tail -20

echo ""
echo "🎉 Migration Complete!"
echo "N8N is now running on PostgreSQL persistence."
echo "Monitor logs to ensure no SQLite warnings appear."
