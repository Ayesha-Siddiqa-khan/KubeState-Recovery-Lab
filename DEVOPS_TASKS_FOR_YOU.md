# DevOps Tasks For You

Use this as your practical project checklist.

## Local

- Start Docker Desktop.
- Build the image with `docker build -t kubestate-recovery-lab-api:local .`.
- Run PostgreSQL and Redis locally for API testing.

## AWS

- Create or choose an EC2 key pair.
- Fill `terraform/terraform.tfvars` only if you need to override defaults.
- Run `terraform init`, `terraform plan`, and `terraform apply`.
- Add the Terraform output `github_actions_oidc_role_arn` to GitHub Secret `AWS_ROLE_TO_ASSUME`.
- Add the control-plane kubeconfig helper output to GitHub Secret `KUBE_CONFIG_DATA`.
- Add the database password to GitHub Secret `POSTGRES_PASSWORD`.

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
