# App Summary

KubeState Recovery Lab is a DevOps portfolio project that demonstrates stateful workload operations on a self-managed Kubernetes cluster.

## Backend

- FastAPI
- PostgreSQL for durable item records
- Redis for visit counter state

## Main API Routes

- `GET /health`
- `GET /ready`
- `POST /items`
- `GET /items`
- `POST /visits`
- `GET /visits`
- `GET /db-check`
- `GET /redis-check`

## DevOps Focus

The application is intentionally simple. The real project value is proving persistent storage, backup, restore, failure recovery, and monitoring readiness.

