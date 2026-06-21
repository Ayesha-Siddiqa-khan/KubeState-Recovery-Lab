# Backup And Restore

## Backup Goal

Create repeatable PostgreSQL backups using `pg_dump` and upload them to S3-compatible object storage.

## Restore Goal

Restore a selected backup into a clean namespace to prove that data recovery works outside the original application namespace.

## Backup Path Pattern

```text
s3://PROJECT_BUCKET/postgres-backups/YYYY-MM-DD/database-backup-HH-MM-SS.sql
```

## Manual Backup Test

Use:

```bash
kubectl delete job postgres-manual-backup -n stateful-app --ignore-not-found
kubectl apply -f k8s/backup/postgres-manual-backup-job.yaml
kubectl logs job/postgres-manual-backup -n stateful-app
```

## Manual Restore Test

Use the full procedure in:

```text
k8s/testing/restore-test.md
```

## Success Criteria

- Backup file exists in S3.
- Restore Job completes successfully.
- Restored database contains expected records.
