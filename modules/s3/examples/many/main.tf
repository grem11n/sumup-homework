# The easiest way to create multiple buckets is to invoke the module multiple times
# like it's shown in the simple-bucket example
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

# However, if you totally want to go with the for_each aproach. For example, if your buckets
# are genrally identical except for the name, you can do it like this.
# Inspired by: https://oneuptime.com/blog/post/2026-02-23-how-to-use-module-for-each-in-terraform/view#basic-syntax
module "multiple_buckets" {
  source = "../../"

  for_each = {
    bucket-1 = { acl = "private", environment = "staging" }
    bucket-2 = { acl = "public", environment = "production" }
  }

  bucket_name = each.key
  owner       = "my-team"
  access      = each.value.acl
  environment = each.value.environment
}
