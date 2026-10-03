module "my_team_bucket_simple" {
  source = "../../"

  bucket_name = "my-bucket"
  owner       = "my-team"
  access      = "private" # only `private` or `public` are allowed
  environment = "dev"
}

module "my_public_bucket_simple" {
  source = "../../"

  bucket_name = "my-bucket" # it will get a suffix `-public`
  owner       = "my-team"
  access      = "public" # only `private` or `public` are allowed
  environment = "dev"
}
