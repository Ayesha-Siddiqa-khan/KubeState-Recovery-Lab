#!/usr/bin/env bash
set -euo pipefail

# Removes application resources from the lab namespaces.
# PVCs are not deleted unless DELETE_PVCS=true is set.

kubectl delete -f k8s/app/ --ignore-not-found
kubectl delete -f k8s/backup/postgres-backup-cronjob.yaml --ignore-not-found
kubectl delete -f k8s/redis/ --ignore-not-found
kubectl delete -f k8s/postgres/ --ignore-not-found

if [[ "${DELETE_PVCS:-false}" == "true" ]]; then
  kubectl delete pvc -n stateful-app --all --ignore-not-found
  kubectl delete pvc -n stateful-restore-test --all --ignore-not-found
else
  echo "PVCs were kept. Set DELETE_PVCS=true to remove persistent data."
fi
