#!/usr/bin/env python3
"""
N8n-like trigger simulation: Query database and send table content to Retool
This script simulates n8n workflow that fetches data from PostgreSQL and sends to Retool dashboard
"""

import json
import os
import sys
from datetime import datetime

# For local testing, use psycopg2 if available
try:
    import psycopg2
    from psycopg2.extras import RealDictCursor
    HAS_PSYCOPG2 = True
except ImportError:
    HAS_PSYCOPG2 = False
    print("psycopg2 not installed. Install with: pip install psycopg2-binary")

def get_db_connection():
    """Get database connection (Neon)"""
    # For local testing
    if os.getenv('USE_LOCAL_DB'):
        return {
            'host': 'localhost',
            'port': 5432,
            'database': 'n8n_dispatch',
            'user': 'postgres',
            'password': 'SecurePass2025!@#'
        }
    # For Neon
    else:
        return {
            'host': 'ep-soft-wave-ab54c4oo-pooler.eu-west-2.aws.neon.tech',
            'port': 5432,
            'database': 'n8n_dispatch',
            'user': 'retool_readonly',
            'password': 'SecurePass2025!@#',
            'sslmode': 'require',
            'options': 'endpoint=ep-soft-wave-ab54c4oo-pooler'  # Required for Neon pooled connection
        }

def query_jobs():
    """Query jobs table and return data"""
    if not HAS_PSYCOPG2:
        # Mock data for demonstration
        return [
            {
                'id': 1,
                'job_id': 'JOB-2025-001',
                'phone': '+447700900001',
                'status': 'QUEUED',
                'consent_status': 'PENDING',
                'created_at': '2025-10-17T07:22:20.317703+00:00',
                'priority': 'CRITICAL'
            },
            {
                'id': 2,
                'job_id': 'JOB-2025-002',
                'phone': '+447700900002',
                'status': 'QUEUED',
                'consent_status': 'PENDING',
                'created_at': '2025-10-18T03:22:20.317703+00:00',
                'priority': 'HIGH'
            }
        ]

    conn_params = get_db_connection()
    try:
        conn = psycopg2.connect(**conn_params)
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # Query with priority calculation (like Retool dashboard)
        cursor.execute("""
            SELECT
                id,
                job_id,
                phone,
                status,
                consent_status,
                created_at,
                CASE
                    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '48 hours' THEN 'CRITICAL'
                    WHEN consent_status = 'PENDING' AND created_at < NOW() - INTERVAL '24 hours' THEN 'HIGH'
                    ELSE 'NORMAL'
                END as priority
            FROM jobs
            WHERE consent_status = 'PENDING'
            ORDER BY created_at ASC
            LIMIT 10
        """)

        results = cursor.fetchall()
        return [dict(row) for row in results]

    except Exception as e:
        print(f"Database error: {e}")
        return []
    finally:
        if 'conn' in locals():
            conn.close()

def send_to_retool(data):
    """Simulate sending data to Retool (in real n8n, this would be an HTTP request)"""
    print("🚀 Sending data to Retool dashboard...")
    print("📊 Data payload:")
    print(json.dumps(data, indent=2, default=str))

    # In real n8n workflow, this would be:
    # - HTTP Request node to Retool API
    # - Or direct database insert if Retool allows it
    # - Or webhook to trigger Retool query refresh

    print("✅ Data sent successfully (simulation)")

def main():
    print("🔄 N8n Trigger Simulation: Database → Retool")
    print("=" * 50)

    # Query database
    print("📡 Querying database...")
    jobs_data = query_jobs()

    if not jobs_data:
        print("❌ No data found")
        return

    print(f"📋 Found {len(jobs_data)} pending jobs")

    # Send to Retool
    send_to_retool(jobs_data)

    print("\n🎯 Simulation complete!")
    print("In real n8n:")
    print("1. Schedule Trigger → PostgreSQL Query → Transform → HTTP Request to Retool")
    print("2. Or use Retool's API to update dashboard data")

if __name__ == "__main__":
    main()