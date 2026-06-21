#!/usr/bin/env bash
set -euo pipefail

# Runs a one-off PostgreSQL backup Job for testing.

kubectl delete job postgres-manual-backup -n stateful-app --ignore-not-found
kubectl apply -f k8s/backup/postgres-manual-backup-job.yaml
kubectl wait --for=condition=complete job/postgres-manual-backup -n stateful-app --timeout=180s
kubectl logs job/postgres-manual-backup -n stateful-app
