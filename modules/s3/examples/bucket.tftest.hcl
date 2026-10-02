run "simple_bucket_tests" {
  command = plan

  module {
    source = "./simple-bucket/"
  }

  assert {
    condition     = module.my_team_bucket_simple.aws_s3_bucket.s3_bucket.bucket == "sumup-my-team-bucket-dev"
    error_message = "Bucket name violates the naming convention: `sumup-[a-z0-9-]+-[a-z]+(-)?(private|public)?`"
  }
}
