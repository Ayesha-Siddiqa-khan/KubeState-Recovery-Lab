locals {
  github_oidc_subject = "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]

  tags = {
    Name                   = "${local.resource_prefix}-github-actions-oidc"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "github-actions-oidc-provider"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "false"
  }
}

resource "aws_iam_role" "github_actions_deploy" {
  name        = "${local.resource_prefix}-gha-deploy"
  description = "GitHub Actions deploy role for ECR push and self-managed Kubernetes rollout."

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
            "token.actions.githubusercontent.com:sub" = local.github_oidc_subject
          }
        }
      }
    ]
  })

  tags = {
    Name                   = "${local.resource_prefix}-gha-deploy"
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "github-actions-deploy-role"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "false"
  }
}

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "${local.resource_prefix}-gha-deploy"
  description = "Least-scoped deployment permissions for GitHub Actions."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "EcrAuth"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "FastApiImagePush"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetDownloadUrlForLayer",
          "ecr:InitiateLayerUpload",
          "ecr:ListImages",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.fastapi.arn
      },
      {
        Sid      = "ReadDeploymentMetadata"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter"]
        Resource = aws_ssm_parameter.postgres_backup_bucket_name.arn
      },
      {
        Sid      = "DescribeSecurityGroups"
        Effect   = "Allow"
        Action   = ["ec2:DescribeSecurityGroups"]
        Resource = "*"
      },
      {
        Sid    = "TemporarilyOpenKubernetesApi"
        Effect = "Allow"
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "arn:aws:ec2:${var.region}:${data.aws_caller_identity.current.account_id}:security-group/*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/Project"   = var.project_name
            "aws:ResourceTag/ManagedBy" = "TerraPilot"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}
