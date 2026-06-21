# Monitoring Plan

## What To Monitor

- FastAPI `/health`
- FastAPI `/ready`
- PostgreSQL pod readiness
- PostgreSQL active connections
- PostgreSQL slow queries
- Redis pod readiness
- Redis persistence behavior
- PVC usage
- Pod restarts
- Node disk pressure

## Why These Signals Matter

Stateful workloads can fail in ways that stateless services do not. A pod can be running while the database is unavailable, a PVC can run out of space, or a restore process can fail silently if logs are not checked.

## Current Scope

This file is a monitoring plan only. Prometheus, Grafana, exporters, dashboards, and alert rules should be installed and tested after the self-managed cluster is running.
