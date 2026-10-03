module "team_localtest_basic_iam" {
  # Path is hardcoded assuming the current structure
  source    = "../modules/team-setup"
  team_name = "localtest"
  # This is kind of a convention over configuration approach
  team_iam_role = "aws:arn:iam:${local.account_id}:role/team-localtest"
}
