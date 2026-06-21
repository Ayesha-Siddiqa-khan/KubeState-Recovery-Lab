resource "aws_ecr_repository" "fastapi" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name                   = var.ecr_repository_name
    Project                = var.project_name
    TerraPilotProject      = var.project_name
    TerraPilotResourceType = "ecr-repository"
    Environment            = var.environment
    ManagedBy              = "TerraPilot"
    CostSensitive          = "false"
  }
}

resource "aws_ecr_lifecycle_policy" "fastapi" {
  repository = aws_ecr_repository.fastapi.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the last 20 pushed images."
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 20
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_pull_fastapi" {
  name        = "${local.resource_prefix}-ecr-pull-fastapi"
  description = "Allow Kubernetes EC2 nodes to pull the FastAPI image from ECR."

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
        Sid    = "FastApiImagePull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = aws_ecr_repository.fastapi.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terrapilot_ecr_pull_fastapi" {
  role       = aws_iam_role.terrapilot_ec2_userdata.name
  policy_arn = aws_iam_policy.ecr_pull_fastapi.arn
}
