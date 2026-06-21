# Disaster Recovery

TODO(Phase 2): Replace this planning document with tested recovery evidence.

## Recovery Scenario

The main PostgreSQL database is unavailable or lost. A backup stored in S3 must be restored into a clean namespace.

## Recovery Objectives

- Prove that backups are usable.
- Prove that restore can happen outside the original namespace.
- Record the commands and logs so another engineer can follow the process.

## Planned Recovery Steps

1. Identify the backup file.
2. Create or verify the restore namespace.
3. Deploy the restore target.
4. Run the restore Job.
5. Validate restored rows.
6. Capture evidence.

## Lessons To Document

- Restore time
- Any errors encountered
- Any manual steps required
- Improvements for a future production design

