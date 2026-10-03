mock_provider "aws" {}

run "empty_inputs_create_nothing" {
  command = plan

  assert {
    condition = (length(output.role_arns) == 0 &&
      length(output.policy_arns) == 0 &&
    length(output.user_arns) == 0)
    error_message = "The IAM root must create nothing without input maps."
  }
}

run "role_policy_user_and_attachments" {
  command = plan

  override_data {
    target = module.roles["app_vm"].data.aws_iam_policy_document.trust
    values = {
      json = <<-POLICY
        {"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"sts:AssumeRole","Principal":{"Service":"ec2.amazonaws.com"}}]}
      POLICY
    }
  }

  override_data {
    target = module.policies["bucket_read"].data.aws_iam_policy_document.this
    values = {
      json = <<-POLICY
        {"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"s3:GetObject","Resource":"arn:aws:s3:::test-example-bucket/*"}]}
      POLICY
    }
  }

  variables {
    roles = {
      app_vm = {
        name                    = "test-app-vm"
        create_instance_profile = true
        trust = {
          principals = { Service = ["ec2.amazonaws.com"] }
        }
      }
    }

    policies = {
      bucket_read = {
        name        = "test-bucket-read"
        description = "Read objects from one bucket"
        statements = {
          ReadObjects = {
            actions   = ["s3:GetObject"]
            resources = ["arn:aws:s3:::test-example-bucket/*"]
          }
        }
      }
    }

    users = {
      integration = { name = "test-integration" }
    }

    role_policy_attachments = {
      bucket_read = { role_key = "app_vm", policy_key = "bucket_read" }
    }

    user_policy_attachments = {
      bucket_read = { user_key = "integration", policy_key = "bucket_read" }
    }
  }

  assert {
    condition = (length(output.role_arns) == 1 &&
      length(output.instance_profile_names) == 1 &&
      length(output.policy_arns) == 1 &&
    length(output.user_arns) == 1)
    error_message = "One role, instance profile, policy, and user should be planned."
  }

  assert {
    condition = (length(aws_iam_role_policy_attachment.this) == 1 &&
    length(aws_iam_user_policy_attachment.this) == 1)
    error_message = "The named policy must attach to both requested principals."
  }
}
