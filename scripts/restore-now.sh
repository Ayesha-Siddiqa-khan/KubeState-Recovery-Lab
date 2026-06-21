#!/usr/bin/env bash
set -euo pipefail

# Runs the restore workflow after postgres-restore-secret.yaml has a real BACKUP_FILE_PATH.

kubectl apply -f k8s/namespaces/restore-namespace.yaml
kubectl apply -f k8s/restore/postgres-restore-secret.yaml
kubectl apply -f k8s/restore/postgres-restore-service.yaml
kubectl apply -f k8s/restore/postgres-restore-statefulset.yaml
kubectl rollout status statefulset/postgres-restore -n stateful-restore-test

kubectl delete job postgres-restore -n stateful-restore-test --ignore-not-found
kubectl apply -f k8s/restore/postgres-restore-job.yaml
kubectl wait --for=condition=complete job/postgres-restore -n stateful-restore-test --timeout=300s
kubectl logs job/postgres-restore -n stateful-restore-test
