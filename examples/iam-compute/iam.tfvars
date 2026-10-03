# Example only. This file is loaded only when passed with -var-file.
# Replace the bucket name and IAM names before planning in your account.
roles = {
  app_vm = {
    name                    = "example-app-vm-role"
    create_instance_profile = true
    instance_profile_name   = "example-app-vm-profile"
    trust = {
      principals = { Service = ["ec2.amazonaws.com"] }
    }
  }
}

policies = {
  app_bucket_read = {
    name        = "example-app-bucket-read"
    description = "Read objects from one application bucket"
    statements = {
      ReadObjects = {
        actions   = ["s3:GetObject"]
        resources = ["arn:aws:s3:::replace-with-your-bucket/*"]
      }
    }
  }
}

role_policy_attachments = {
  app_bucket_read = {
    role_key   = "app_vm"
    policy_key = "app_bucket_read"
  }
}
