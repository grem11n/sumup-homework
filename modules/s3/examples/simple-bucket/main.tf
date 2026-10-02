module "my_team_bucket_simple" {
  source = "../../"

  bucket_name = "my-bucket"
  owner       = "my-team"
  owner_role  = "teams/my-team" # can be a reference like aws_iam_role.my_team_role.name
  access      = "private"       # only `private` or `public` are allowed
  environment = "dev"
}
