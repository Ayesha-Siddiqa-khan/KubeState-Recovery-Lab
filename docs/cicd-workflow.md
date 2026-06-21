# CI/CD Workflow

This document explains the GitHub Actions workflow in `.github/workflows/deploy.yml`.

## What The Workflow Does

On every push to the `main` branch, the workflow checks whether files changed under:

- `app/**`
- `Dockerfile`
- `requirements.txt`
- `k8s/**`
- `.github/workflows/deploy.yml`

If they did, it builds the FastAPI Docker image, pushes it to Amazon ECR, connects to the self-managed Kubernetes cluster using a kubeconfig secret, applies plain Kubernetes manifests, updates the FastAPI Deployment image, and verifies the rollout.

## Why OIDC Is Better Than Static AWS Keys

OIDC lets GitHub Actions request short-lived AWS credentials for a specific workflow run. This is safer than storing long-lived AWS access keys in GitHub secrets because there are no permanent AWS keys to rotate or accidentally leak.

The workflow uses:

```yaml
permissions:
  contents: read
  id-token: write
```

The `id-token: write` permission allows GitHub Actions to request an OIDC token and assume the AWS IAM role stored in `AWS_ROLE_TO_ASSUME`.

## Required GitHub Secrets

Create only these repository secrets:

- `AWS_ROLE_TO_ASSUME` - Terraform output `github_actions_oidc_role_arn`
- `KUBE_CONFIG_DATA` - public base64 kubeconfig generated on the control-plane node
- `POSTGRES_PASSWORD` - runtime PostgreSQL password used for both PostgreSQL and FastAPI

No GitHub repository variables are required. The workflow keeps stable project values in `.github/workflows/deploy.yml`.

Generate `KUBE_CONFIG_DATA` on the Kubernetes control-plane node:

```bash
generate-kubeconfig-github
cat /home/ubuntu/kubeconfig-public.b64
```

## Required GitHub Variables

No repository variables are required.

## Docker Image Tags

The workflow creates two tags for every image:

- Git commit SHA, for example `a1b2c3d4...`
- `latest`

The SHA tag is used for deployment because it is immutable and easy to trace back to a commit. The `latest` tag is pushed for convenience during manual testing.

## How Deployment Works With A Self-Managed Cluster

Because this project does not use EKS, the workflow does not call EKS-specific commands. Instead, it decodes `KUBE_CONFIG_DATA` and uses plain `kubectl`.

If no Ready worker node is present, the workflow removes the standard control-plane taints so this lab can still schedule workloads on a single-node cluster. When workers are Ready, the workflow leaves control-plane taints unchanged.

Normal deployment applies:

- namespaces
- cert-manager ClusterIssuer
- PostgreSQL manifests
- Redis manifests
- FastAPI manifests
- backup CronJob manifests

PostgreSQL stores data under `/var/lib/postgresql/data/pgdata` inside the mounted PVC. This avoids first-boot failures on ext4-backed EBS volumes that include filesystem metadata at the mount root.

Restore manifests are not applied during normal deployments because they are meant for disaster recovery tests.

## What To Check If Deployment Fails

Check these areas first:

- GitHub OIDC trust policy allows the repository and branch.
- `AWS_ROLE_TO_ASSUME` points to the Terraform-created OIDC role ARN.
- `KUBE_CONFIG_DATA` is valid and points to the self-managed cluster.
- The EC2 security group allows the GitHub runner to reach the Kubernetes API server.
- The FastAPI image builds successfully.
- Pods can pull from ECR.

Useful commands:

```bash
kubectl -n stateful-app get pods -o wide
kubectl -n stateful-app describe deployment fastapi
kubectl -n stateful-app logs -l app=fastapi --tail=100
kubectl -n stateful-app get events --sort-by=.metadata.creationTimestamp
```

## Evidence Screenshots To Add

Add these screenshots to the GitHub repository after the workflow runs:

- Successful GitHub Actions run
- ECR image with SHA and `latest` tags
- Kubernetes rollout success
- `kubectl get pods -n stateful-app`
- FastAPI endpoint responding through HTTPS ingress
- Failed rollout logs if you intentionally test a bad image
