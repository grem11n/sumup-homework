mock_provider "aws" {}
variables {
  bucket_name = "my-bucket"
  owner       = "my-team"
  owner_role  = "teams/my-team"
  access      = "private"
  environment = "dev"
}

run "bucket_name" {
  command = plan

  assert {
    condition     = aws_s3_bucket.s3_bucket.bucket == "sumup-my-bucket-dev"
    error_message = "Bucket name violates the naming convention: `sumup-[a-z0-9-]+-[a-z]+(-)?(private|public)?`"
  }
}
