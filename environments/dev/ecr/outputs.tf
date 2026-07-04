output "repository_urls" {
  description = "Map of ECR repository names to their repository URLs"
  value = {
    for key, repo in aws_ecr_repository.app :
    key => repo.repository_url
  }
}

output "repository_arns" {
  description = "Map of ECR repository names to their ARNs"
  value = {
    for key, repo in aws_ecr_repository.app :
    key => repo.arn
  }
}

output "repository_registry_id" {
  description = "The registry ID (AWS account ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "repositories" {
  description = "Complete ECR repository objects"
  value = {
    for key, repo in aws_ecr_repository.app :
    key => {
      name            = repo.repository_name
      url             = repo.repository_url
      arn             = repo.arn
      registry_id     = repo.registry_id
      repository_uri  = repo.repository_url
    }
  }
}
