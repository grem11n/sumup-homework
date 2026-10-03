module "my_bucket_complete" {
  source = "../../"

  bucket_name = "my-bucket"
  owner       = "my-team"
  access      = "private" # only `private` or `public` are allowed
  environment = "dev"
  extra_tags = {
    "Project" = "Manhattan"
  }
  allowed_roles = [
    "aws:arn:iam:111122223333:role/my-team",
    "aws:arn:iam:111122223333:role/friendly-team",
  ]
  lifecycle_rules = {
    # omited, coz they can be huge. Check aws_s3_bucket_lifecycle_configuration
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration
    # The API should be the same as for the `rules` block there.
  }
}
