# DevOps Tasks For You

Use this as your practical project checklist.

## Local

- Start Docker Desktop.
- Build the image with `docker build -t kubestate-recovery-lab-api:local .`.
- Run PostgreSQL and Redis locally for API testing.

## AWS

- Create or choose an EC2 key pair.
- Fill `infra/terraform.tfvars`.
- Run `terraform init`, `terraform plan`, and `terraform apply`.

## Kubernetes

- Bootstrap Kubernetes with kubeadm on EC2.
- Install a CNI plugin.
- Install AWS EBS CSI driver.
- Install NGINX Ingress Controller.
- Install cert-manager.
- Apply manifests from `k8s/`.

## Evidence

- Screenshot FastAPI HTTPS endpoint.
- Screenshot PostgreSQL and Redis PVCs.
- Screenshot S3 backup object.
- Screenshot restore Job logs.
- Screenshot Grafana dashboard.
- Screenshot pod and node recovery tests.

