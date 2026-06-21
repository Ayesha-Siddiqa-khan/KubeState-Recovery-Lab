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

Create these repository secrets:

- `AWS_REGION` - AWS region, for example `us-east-1`
- `AWS_ROLE_TO_ASSUME` - IAM role ARN trusted by GitHub OIDC
- `ECR_REPOSITORY` - ECR repository name, for example `kubestate-recovery-lab-fastapi`
- `KUBECONFIG_B64` - base64-encoded kubeconfig for the self-managed cluster

`AWS_ROLE_TO_ASSUME` should be a GitHub OIDC role, not the EC2 node instance role. It needs permissions to log in to ECR and push images to the FastAPI repository.

To create `KUBECONFIG_B64` locally:

```bash
base64 -w 0 ~/.kube/config
```

On macOS:

```bash
base64 ~/.kube/config | tr -d '\n'
```

## Required GitHub Variables

Create these repository variables:

- `APP_NAME` - Kubernetes Deployment name, expected value: `fastapi-api`
- `K8S_NAMESPACE` - Kubernetes namespace, expected value: `stateful-app`

## Docker Image Tags

The workflow creates two tags for every image:

- Git commit SHA, for example `a1b2c3d4...`
- `latest`

The SHA tag is used for deployment because it is immutable and easy to trace back to a commit. The `latest` tag is pushed for convenience during manual testing.

## How Deployment Works With A Self-Managed Cluster

Because this project does not use EKS, the workflow does not call EKS-specific commands. Instead, it decodes the kubeconfig from `KUBECONFIG_B64` and uses plain `kubectl`.

Normal deployment applies:

- namespaces
- cert-manager ClusterIssuer
- PostgreSQL manifests
- Redis manifests
- FastAPI manifests
- backup CronJob manifests

Restore manifests are not applied during normal deployments because they are meant for disaster recovery tests.

## What To Check If Deployment Fails

Check these areas first:

- GitHub OIDC trust policy allows the repository and branch.
- `AWS_ROLE_TO_ASSUME` points to the correct role ARN.
- `ECR_REPOSITORY` matches the ECR repository name.
- `KUBECONFIG_B64` is valid and points to the self-managed cluster.
- The EC2 security group allows the GitHub runner to reach the Kubernetes API server.
- The FastAPI image builds successfully.
- The Kubernetes Deployment name matches `APP_NAME`.
- The namespace matches `K8S_NAMESPACE`.
- Pods can pull from ECR.

Useful commands:

```bash
kubectl -n stateful-app get pods -o wide
kubectl -n stateful-app describe deployment fastapi-api
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
