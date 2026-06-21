# Infrastructure

The infrastructure for this project lives in `terraform/`.

## AWS Resources

- VPC
- Public subnets
- Internet gateway
- Route table
- Security group
- EC2 control-plane node
- EC2 worker nodes
- IAM role and instance profile
- S3 bucket for PostgreSQL backups
- ECR repository for FastAPI images
- GitHub Actions OIDC provider and deploy role

## Important Design Choice

This project does not use EKS. It uses EC2 so the project can demonstrate self-managed Kubernetes operations.

## Commands

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

Destroy resources when finished:

```bash
terraform destroy
```
