# KubeState Recovery Lab

Beginner-friendly DevOps portfolio project for running and recovering stateful workloads on a self-managed Kubernetes cluster.

> Current status: infrastructure, CI/CD workflow, Kubernetes manifests, backup/restore manifests, and documentation are scaffolded for a GitHub portfolio. FastAPI application code is still intentionally left for a later implementation step.

## Recruiter Summary

This project demonstrates the ability to operate stateful workloads on Kubernetes, including persistent storage, backup, restore, and failure recovery. It goes beyond a simple stateless deployment by proving that application data can survive pod restarts and can be recreated from backup in a clean namespace.

## What This Project Will Build

KubeState Recovery Lab will deploy a small FastAPI backend backed by PostgreSQL and Redis inside Kubernetes. PostgreSQL and Redis will run as StatefulSets with PersistentVolumeClaims. PostgreSQL backups will be created by a Kubernetes CronJob and uploaded to S3-compatible object storage. A restore Job will prove that a backup can recreate the database in a separate namespace.

## Why Stateful Kubernetes Workloads Matter

Stateless applications are easier to run because pods can be replaced without losing important data. Stateful workloads are more operationally sensitive because data, storage, backups, restore procedures, and failure behavior must be designed deliberately.

This lab focuses on the practical skills recruiters expect from a DevOps or Cloud Engineer:

- Deploying services on Kubernetes
- Understanding StatefulSets and PVCs
- Operating PostgreSQL and Redis inside a cluster
- Planning backup and restore workflows
- Testing pod and node failure scenarios
- Explaining tradeoffs clearly

## Architecture Overview

```text
User
  |
  v
NGINX Ingress + TLS
  |
  v
FastAPI Deployment
  |                         |
  v                         v
PostgreSQL StatefulSet      Redis StatefulSet
  |                         |
  v                         v
PostgreSQL PVC              Redis PVC
  |
  v
Backup CronJob -> S3-compatible object storage
  |
  v
Restore Job -> clean restore namespace
```

## Planned API Routes

- `GET /health` - returns application health
- `GET /ready` - checks PostgreSQL and Redis connectivity
- `POST /items` - creates an item in PostgreSQL
- `GET /items` - lists items from PostgreSQL
- `POST /visits` - increments a Redis-backed visit counter
- `GET /visits` - returns the Redis visit counter
- `GET /db-check` - confirms PostgreSQL connectivity
- `GET /redis-check` - confirms Redis connectivity

## Repository Structure

```text
kubestate-recovery-lab/
  app/                 FastAPI application placeholder files
  infra/               Terraform for AWS EC2 self-managed Kubernetes infrastructure
  k8s/                 Plain Kubernetes YAML manifests and test notes
  docs/                Recruiter-friendly architecture and operations docs
  .github/workflows/   GitHub Actions build and deploy workflow
  evidence/            Screenshot and command-output placeholders
  scripts/             Safe Phase 1 script placeholders
  README.md            Main project guide
```

## Deployment Flow

Planned flow:

1. Provision AWS infrastructure from `infra/`.
2. Bootstrap Kubernetes on the EC2 nodes.
3. Install a CNI, NGINX Ingress Controller, cert-manager, and the AWS EBS CSI driver.
4. Build and push the FastAPI container image.
5. Create the `stateful-app` namespace.
6. Apply PostgreSQL manifests.
7. Apply Redis manifests.
8. Apply FastAPI Deployment, Service, Secret, ConfigMap, and Ingress.
9. Verify `/health`, `/ready`, `/db-check`, and `/redis-check`.
10. Confirm PVCs are bound.
11. Capture evidence screenshots for GitHub.

Useful command sequence:

```bash
kubectl apply -f k8s/namespaces/
kubectl apply -f k8s/ingress/cluster-issuer.yaml
kubectl apply -f k8s/postgres/
kubectl apply -f k8s/redis/
kubectl apply -f k8s/app/
kubectl apply -f k8s/backup/s3-backup-secret.yaml
kubectl apply -f k8s/backup/postgres-backup-cronjob.yaml
```

## Backup Flow

1. Backup CronJob connects to PostgreSQL.
2. `pg_dump` creates a timestamped SQL backup.
3. Backup is uploaded to S3 using credentials from a Kubernetes Secret.
4. Backup path uses this pattern:

```text
s3://PROJECT_BUCKET/postgres-backups/YYYY-MM-DD/database-backup-HH-MM-SS.sql
```

## Restore Flow

1. Create `stateful-restore-test` namespace.
2. Deploy a clean PostgreSQL restore target.
3. Download the selected backup from S3.
4. Restore the SQL file.
5. Query the restored database to prove records exist.

## Failure Testing Flow

TODO(Phase 2): Run each test against a live cluster and replace placeholders with evidence.

Planned tests:

- PostgreSQL pod deletion test
- Redis pod deletion test
- Node drain test
- Disaster recovery restore test

## Monitoring Plan

Metrics to track:

- Disk usage
- PVC usage
- Pod restarts
- PostgreSQL availability
- PostgreSQL connections
- PostgreSQL slow queries
- Redis availability
- FastAPI health

## PostgreSQL in Kubernetes vs RDS

Running PostgreSQL inside Kubernetes is useful for learning StatefulSets, PVCs, backups, and recovery. For many production teams, a managed database such as RDS is safer because backups, patching, replication, and failover are handled by the cloud provider.

This project intentionally runs PostgreSQL inside Kubernetes to demonstrate stateful workload operations, not because it is always the best production choice.

## When Not To Run Databases Inside Kubernetes

Avoid running production databases inside Kubernetes when:

- The team does not have database operations experience
- Storage behavior is not well understood
- Backup and restore are not tested
- Multi-zone failover is required but not designed
- A managed database is available and meets the business needs

## Evidence Checklist

Replace each placeholder with real screenshots or logs after the live cluster tests:

- [ ] FastAPI running through HTTPS ingress
- [ ] PostgreSQL PVC bound
- [ ] Redis PVC bound
- [ ] Successful backup file in S3
- [ ] Restore Job logs
- [ ] Restored data query result
- [ ] Grafana dashboard
- [ ] Pod deletion and recovery
- [ ] Node drain test
- [ ] Final application working after recovery

## LinkedIn Portfolio Angle

Suggested project headline:

```text
KubeState Recovery Lab: Running PostgreSQL and Redis as recoverable stateful workloads on Kubernetes
```

Suggested short description:

```text
I built a Kubernetes recovery lab that demonstrates StatefulSets, PersistentVolumeClaims, PostgreSQL backups to S3, restore into a clean namespace, Redis persistence, failure testing, and a monitoring plan with Prometheus and Grafana.
```

## Phase Roadmap

- Phase 1: Repository scaffold, documentation route, evidence placeholders
- Phase 2: Terraform infrastructure, Kubernetes manifests, and CI/CD workflow
- Phase 3: FastAPI app code and Dockerfile implementation
- Phase 4: Live cluster bootstrap, backup/restore execution, and failure testing evidence
- Phase 5: LinkedIn-ready screenshots and final GitHub polish

## Current Restrictions

- No Helm
- No EKS
- No Jenkins
- No Argo CD yet
- No application code implementation in this step
- No real secrets committed to GitHub
- Plain Kubernetes YAML only
- Beginner-friendly explanations
