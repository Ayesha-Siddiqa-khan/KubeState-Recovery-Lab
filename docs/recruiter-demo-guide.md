# Recruiter Demo Guide

TODO(Phase 2): Turn this into a live demo script after the project runs on a cluster.

## 60-Second Explanation

KubeState Recovery Lab is a Kubernetes project that demonstrates stateful workload operations. It runs FastAPI with PostgreSQL and Redis inside Kubernetes, uses PersistentVolumeClaims for data persistence, backs up PostgreSQL to S3, restores into a clean namespace, and documents failure testing for pod deletion, Redis restart, node drain, and disaster recovery.

## What This Proves

- I understand more than stateless Kubernetes deployments.
- I can work with StatefulSets and persistent storage.
- I can design a backup and restore process.
- I can test failure scenarios and document evidence.
- I can explain tradeoffs clearly to technical and non-technical reviewers.

## LinkedIn Post Draft

```text
I started building KubeState Recovery Lab, a DevOps portfolio project focused on stateful workloads in Kubernetes.

The goal is to go beyond a basic stateless deployment and prove recovery behavior:

- FastAPI running behind HTTPS ingress
- PostgreSQL and Redis running as StatefulSets
- PersistentVolumeClaims for durable state
- PostgreSQL backups to S3 using a Kubernetes CronJob
- Restore into a clean namespace using a Kubernetes Job
- Pod deletion, Redis restart, node drain, and disaster recovery testing
- Monitoring plan with Prometheus and Grafana

This project helped me practice one of the most important Kubernetes topics: what happens when the application data matters.
```

## Demo Evidence To Show

- Application endpoint working through HTTPS
- PostgreSQL and Redis PVCs
- Backup file in S3
- Restore Job logs
- Restored data query
- Grafana dashboard
- Failure recovery screenshots

