# PostgreSQL In Kubernetes vs RDS

TODO(after live deployment): Add real observations after the lab is tested on AWS.

## PostgreSQL In Kubernetes

Benefits:

- Good for learning StatefulSets, PVCs, backups, and restore workflows
- Keeps the whole lab inside Kubernetes
- Demonstrates operational understanding

Tradeoffs:

- Storage and recovery require careful design
- Database upgrades and patching are the team's responsibility
- Failover is not automatic unless deliberately built
- Backup testing is mandatory

## Managed PostgreSQL Such As RDS

Benefits:

- Managed backups
- Easier patching
- Built-in operational features
- Better default choice for many production teams

Tradeoffs:

- Less hands-on Kubernetes storage learning
- Cloud-provider dependency
- Some configuration limits

## Portfolio Explanation

This project runs PostgreSQL inside Kubernetes to demonstrate stateful operations. In many production environments, I would still evaluate managed PostgreSQL first.
