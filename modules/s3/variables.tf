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

variable "owner_role" {
  type = string
  # Potentially, can be derived from the team name in `owner`, but this requires context for
  # IAM roles naming conventions that is currently missing
}
