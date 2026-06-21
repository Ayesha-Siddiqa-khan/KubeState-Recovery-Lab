# Storage Design

TODO(Phase 2): Replace placeholders with actual cluster StorageClass and PVC output.

## StorageClass

Document the StorageClass used by the cluster:

```text
kubectl get storageclass
```

## Why StatefulSets Need Stable Storage

StatefulSets are designed for workloads that need stable names and stable storage. When a pod is recreated, Kubernetes can attach the same PersistentVolumeClaim so the workload can continue using its existing data.

## How PVCs Are Created

TODO(Phase 2): Explain the `volumeClaimTemplates` used by PostgreSQL and Redis.

## What Happens When A Pod Is Deleted

Expected behavior:

- The StatefulSet recreates the pod.
- The PVC remains.
- The application data should still exist.

## What Happens During Node Drain

Expected behavior depends on the storage type:

- Cloud block storage may reattach to another node.
- Local storage may keep the pod stuck until the original node returns.

## Local Storage vs Cloud Block Storage

Local storage is useful for learning and simple labs, but it can limit rescheduling. Cloud block storage is more flexible, but it still needs careful backup and restore planning.

