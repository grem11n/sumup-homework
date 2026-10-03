mock_provider "aws" {}

run "wrong_acl" {
  command = plan

  variables {
    bucket_name = "my-bucket"
    owner       = "my-team"
    access      = "parrot"
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

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Should block public acls for private buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Should block public policy for private buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "Should ignore public acl for private buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "Should restrict public buckets for private buckets"
  }

  assert {
    # gosh, this is ugly
    condition = lookup(
      lookup(
        tolist(aws_s3_bucket_server_side_encryption_configuration.this.rule)[0],
      "apply_server_side_encryption_by_default")[0],
      "sse_algorithm"
    ) == "AES256"
    error_message = "Bucket should encrypt objects by default"
  }

  assert {
    # gosh, this is ugly
    condition = lookup(
      lookup(
        tolist(aws_s3_bucket_server_side_encryption_configuration.this.rule)[0],
      "apply_server_side_encryption_by_default")[0],
      "kms_master_key_id"
    ) == "aws/s3"
    error_message = "Bucket should use default key"
  }
}

run "minimal_public_bucket" {
  command = plan

  variables {
    bucket_name = "my-bucket"
    owner       = "my-team"
    access      = "public"
    environment = "dev"
  }

  assert {
    condition     = lookup(aws_s3_bucket_ownership_controls.this.rule[0], "object_ownership") == "BucketOwnerPreferred"
    error_message = "Object ownership should be prefered for public buckets"
  }

  assert {
    condition     = aws_s3_bucket_acl.this.acl == "public-read"
    error_message = "ACL of a public bucket should be public-read"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == false
    error_message = "Should allow public acls for public buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == false
    error_message = "Should allow public policy for public buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == false
    error_message = "Should not ignore public acl for public buckets"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == false
    error_message = "Should not restrict public buckets"
  }
}
