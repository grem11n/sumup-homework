mock_provider "aws" {}

run "wrong_acl" {
  command = plan

  variables {
    bucket_name = "my-bucket"
    owner       = "my-team"
    access      = "all-aboard"
    environment = "dev"
  }

  expect_failures = [
    var.access
  ]
}

run "minimal_private_bucket" {
  command = plan

  variables {
    bucket_name = "my-bucket"
    owner       = "my-team"
    access      = "private"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "sumup-my-bucket-dev"
    error_message = "Bucket name violates the naming convention: `sumup-[a-z0-9-]+-[a-z]+(-)?(private|public)?`"
  }

  assert {
    condition     = lookup(aws_s3_bucket.this.tags, "Owner") == "my-team"
    error_message = "Owner tag mismatch!"
  }

  assert {
    # This is a list of objects with 1 element, thus 0
    condition     = lookup(aws_s3_bucket_abac.this.abac_status[0], "status") == "Enabled"
    error_message = "ABAC should be enabled for the bucket"
  }

  assert {
    condition     = lookup(aws_s3_bucket_ownership_controls.this.rule[0], "object_ownership") == "BucketOwnerEnforced"
    error_message = "Object ownership should be enforced to the bucket owner"
  }

  assert {
    condition     = aws_s3_bucket_acl.this.acl == "private"
    error_message = "ACL of a private bucket should be private!"
  }
}
