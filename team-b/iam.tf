module "team_team-b_basic_iam" {
  # Path is hardcoded assuming the current structure
  source    = "../modules/team-setup"
  team_name = "team-b"
  # This is kind of a convention over configuration approach
  team_iam_role = "aws:arn:iam:${account_id}:role/team-team-b"
}
