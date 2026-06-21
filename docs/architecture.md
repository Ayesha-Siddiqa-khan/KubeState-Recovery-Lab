# Architecture

## High-Level Design

```text
Client
  |
  v
NGINX Ingress Controller
  |
  v
FastAPI Service
  |
  v
FastAPI Deployment
  |                         |
  v                         v
PostgreSQL Service          Redis Service
  |                         |
  v                         v
PostgreSQL StatefulSet      Redis StatefulSet
  |                         |
  v                         v
PostgreSQL PVC              Redis PVC
```

## Core Design Decisions

- FastAPI stays intentionally small so the project focuses on operations.
- PostgreSQL uses a StatefulSet because it needs stable identity and storage.
- Redis uses append-only persistence to demonstrate cache/session recovery.
- Backups are handled inside Kubernetes with a CronJob.
- Restore is tested in a separate namespace to prove recoverability.

## Kubernetes Resource Names

- Main namespace: `stateful-app`
- Restore namespace: `stateful-restore-test`
- FastAPI Deployment: `fastapi`
- FastAPI Service: `fastapi`
- PostgreSQL StatefulSet: `postgres`
- PostgreSQL Service: `postgres`
- Redis StatefulSet: `redis`
- Redis Service: `redis`
- Backup CronJob: `postgres-backup`
- Manual Backup Job: `postgres-manual-backup`
- Restore Job: `postgres-restore`

## Recruiter-Friendly Explanation

This architecture proves that I can deploy an application and also think through what happens when data matters: storage, backups, restore testing, and failure behavior.
