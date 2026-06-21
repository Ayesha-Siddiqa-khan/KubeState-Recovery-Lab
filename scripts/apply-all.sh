#!/usr/bin/env bash
set -euo pipefail

# Applies the normal runtime manifests in a safe order.
# Restore manifests and the manual backup Job are intentionally excluded.

kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/ingress/cluster-issuer.yaml
kubectl apply -f k8s/postgres/
kubectl apply -f k8s/redis/
kubectl apply -f k8s/app/
kubectl apply -f k8s/backup/s3-backup-secret.yaml
kubectl apply -f k8s/backup/postgres-backup-cronjob.yaml

kubectl get pods -n stateful-app -o wide
