# PECR Consent Compliance Implementation

## Overview
This implementation adds Privacy and Electronic Communications Regulations (PECR) compliance to your dispatch pipeline by implementing auditable consent mechanisms for customer communications.

## Files Created/Updated

### 1. `twilio_consent_reply_handler.json`
New n8n workflow that processes customer consent replies (CONFIRM/STOP) and updates the database with immutable audit trails.

**Key Features:**
- Tolerant reply parsing (accepts CONFIRM/YES/Y for consent, STOP/NO for denial)
- **SECURITY FIX**: Targets ONLY the most recent PENDING job to prevent replay attacks
- Updates job status from PENDING_CONSENT to active when consent given
- Maintains immutable audit logs for PECR compliance
- Only processes actionable replies

### 2. `database_migration_pe_cr_consent.sql`
Database schema updates to support consent auditing.

**New Fields:**
- `consent_status`: PENDING/GIVEN/DENIED
- `consent_timestamp`: When consent was given/denied
- `is_first_contact`: Tracks first contact attempts

### 3. `twilio_inbound_handler.json` (Updated)
Enhanced to lock jobs with PENDING_CONSENT status and automatically request consent before any communications.

## Deployment Steps

### 1. Database Migration
```bash
# Connect to your PostgreSQL database and run:
psql -d your_database -f database_migration_pe_cr_consent.sql
```

### 2. Import Workflows to n8n
1. Open your n8n instance
2. Import `twilio_consent_reply_handler.json`
3. Import updated `twilio_inbound_handler.json`
4. Activate both workflows

### 3. Configure Twilio Webhooks
Set up webhooks in Twilio Console:
- **Inbound Messages**: Point to `twilio_inbound_handler.json` webhook URL
- **Consent Replies**: Point to `twilio_consent_reply_handler.json` webhook URL

## Testing the Consent Flow

### Test Scenario
1. Send an inbound message to your Twilio number
2. System should:
   - Create/update job with `consent_status = 'PENDING'`
   - Send consent request: "Reply CONFIRM to accept communications or STOP to opt out..."
3. Customer replies with "CONFIRM"
4. System should:
   - Update job `consent_status = 'GIVEN'`
   - Set job status back to 'New' (unblocks dispatch)
   - Log audit entry

### Verification Queries
```sql
-- Check consent status
SELECT phone, consent_status, consent_timestamp, status FROM jobs WHERE phone = '+1234567890';

-- Check audit trail
SELECT * FROM audit_ledger WHERE contact_id = '+1234567890' ORDER BY created_at DESC;
```

## Compliance Benefits

- **PECR Reg. 22**: Auditable proof of consent for all communications
- **GDPR**: Lawful basis for processing personal data
- **Immutable Audit**: All consent decisions are logged with timestamps
- **Fail-Safe**: Jobs remain locked until explicit consent given

## Security Notes

- PII redaction maintained in sandbox environments
- Consent status prevents unauthorized communications
- All consent changes are audited
- Database constraints ensure valid consent states
- **CRITICAL SECURITY FIX**: Consent replies now target ONLY the most recent PENDING job, preventing replay attacks and incorrect status updates

## Next Steps

1. Deploy to production after testing
2. Monitor consent reply rates
3. Consider adding consent expiry logic if required
4. Review denied consents for process improvements