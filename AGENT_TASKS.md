# Agent Tasks

## Completed

- Created root-level repository structure.
- Added FastAPI backend source in `app/`.
- Added root `Dockerfile` and `requirements.txt`.
- Added Terraform infrastructure in `terraform/`.
- Added plain Kubernetes manifests in `k8s/`.
- Added GitHub Actions CI/CD workflow in `.github/workflows/deploy.yml`.
- Added backup, restore, testing, and monitoring documentation.

## Next

- Start Docker Desktop and build the image locally.
- Run Terraform against AWS.
- Bootstrap the self-managed Kubernetes cluster on EC2.
- Store only `AWS_ROLE_TO_ASSUME`, `KUBE_CONFIG_DATA`, and `POSTGRES_PASSWORD` in GitHub Secrets.
- Deploy manifests and collect evidence screenshots.
