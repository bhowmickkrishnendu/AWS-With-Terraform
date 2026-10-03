# Example only. Terraform does not load this file unless -var-file is supplied.
# Replace names and resource ARNs before using it in an account.
roles = {
  app_vm = {
    name                    = "example-app-vm"
    create_instance_profile = true
    trust = {
      principals = { Service = ["ec2.amazonaws.com"] }
    }
  }
}

policies = {
  read_app_bucket = {
    name        = "example-read-app-bucket"
    description = "Read objects from one application bucket"
    statements = {
      ReadObjects = {
        actions   = ["s3:GetObject"]
        resources = ["arn:aws:s3:::replace-with-your-bucket/*"]
      }
    }
  }
}

users = {
  integration = {
    name = "example-integration-user"
  }
}

role_policy_attachments = {
  app_bucket_read = {
    role_key   = "app_vm"
    policy_key = "read_app_bucket"
  }
}

user_policy_attachments = {
  integration_bucket_read = {
    user_key   = "integration"
    policy_key = "read_app_bucket"
  }
}
