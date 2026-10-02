# ACL with grants is left out of scope as per the task
variable "access" {
  type        = string
  description = "Access type for the bucket: private or public"
  validation {
    condition     = contains(["private", "public"], var.access)
    error_message = "`access` can be either private or public!"
  }
}

variable "bucket_name" {
  type        = string
  description = "Bucket name. It will be prefixed with <sumup-> and added the environment info."
}

variable "environment" {
  type        = string
  description = "Environment of the bucket"
  # Potentially we can add a validation for allowed environments as well
}

variable "extra_tags" {
  type        = map(any)
  description = "Additional tags for the bucket"
  default     = {}
}

variable "owner" {
  type        = string
  description = "Owning team name"
}

variable "lifecycle_rules" {
  # It's not any IRL, you can find the spec here:
  # https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/variables.tf#L249
  type        = list(object(any))
  description = "Lifecycle rules for the bucket"
  default     = []
}
