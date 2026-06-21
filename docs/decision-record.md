# Decision Record

This file tracks important project decisions in a recruiter-friendly way.

## DR-001: Use Plain Kubernetes YAML

Decision: Use plain YAML manifests.

Reason: The Kubernetes layer stays beginner-friendly and avoids Helm so every resource is readable in GitHub.

## DR-002: Run PostgreSQL Inside Kubernetes For Learning

Decision: Deploy PostgreSQL as a StatefulSet.

Reason: This directly demonstrates stateful workload operations, PVC behavior, and restore planning.

## DR-003: Keep FastAPI Intentionally Simple

Decision: Build a small API with only health, readiness, database, Redis, item, and visit routes.

Reason: Application complexity should not distract from the Kubernetes recovery story.

## DR-004: Restore Into A Clean Namespace

Decision: Restore PostgreSQL into `stateful-restore-test`.

Reason: A restore test is stronger when it proves the backup can recreate data outside the original namespace.

## Future Decisions

TODO: Add decisions for image registry naming, final StorageClass validation, S3 provider, ingress hostname, and monitoring setup.

## DR-005: Use Terraform For AWS Infrastructure

Decision: Add Terraform under `infra/` for the AWS VPC, EC2 nodes, S3 backup bucket, and ECR repository.

Reason: Terraform demonstrates infrastructure-as-code skills while keeping Kubernetes manifests plain and easy to review.

## DR-006: Use GitHub Actions With OIDC

Decision: Add a GitHub Actions workflow that authenticates to AWS with OIDC and deploys with plain `kubectl`.

Reason: OIDC avoids long-lived AWS keys, and plain `kubectl` keeps deployment compatible with a self-managed EC2 Kubernetes cluster.
