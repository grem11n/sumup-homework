terraform {
  required_version = "~> 1.16"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.67.0"
    }
  }
  backend "s3" {
    bucket       = "sumup-tf-states"
    key          = "team-<PLACEHOLDER>"
    use_lockfile = true
  }
}
