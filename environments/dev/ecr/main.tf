resource "aws_ecr_repository" "app" {
  for_each = var.repositories

  name                 = "${var.environment}-${each.key}"
  image_tag_mutability = each.value.image_tag_mutability
  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
  encryption_configuration {
    encryption_type = each.value.encryption_type
  }
  force_delete = each.value.force_delete

  tags = merge(
    var.common_tags,
    each.value.tags,
    {
      Name        = "${var.environment}-${each.key}"
      Environment = var.environment
      Module      = "ecr"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_ecr_lifecycle_policy" "app" {
  for_each = var.repositories

  repository = aws_ecr_repository.app[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${each.value.image_retention_count} images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = each.value.image_retention_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Remove untagged images older than ${each.value.lifecycle_days_expired} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.lifecycle_days_expired
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "app" {
  for_each = var.repositories

  repository = aws_ecr_repository.app[each.key].name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPullFromSameAccount"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
        ]
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
