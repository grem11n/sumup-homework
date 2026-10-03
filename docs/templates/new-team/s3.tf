# Strictly speaking, this file is not necessary.
# It's just to show where team's buckets would go
# Normally, I would assume we bootstrap a new team without specific resources
# and let them handle those.
module "my_team_bucket_simple" {
  # It's better to use repo references than paths
  source = "../s3"

  bucket_name = "<PLACEHOLDER>-bucket"
  owner       = "<PLACEHOLDER>"
  access      = "private" # only `private` or `public` are allowed
  environment = "dev"
}
