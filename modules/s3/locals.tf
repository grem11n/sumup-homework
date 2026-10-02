locals {
  name_prefix      = "sumup"
  bucket_name_base = "${local.name_prefix}-${var.bucket_name}-${var.environment}"
  bucket_name      = var.access == "public" ? "${local.bucket_name_base}-public" : local.bucket_name_base
  merged_tags = merge(
    {
      "Name"        = local.bucket_name
      "Owner"       = var.owner
      "Environment" = var.environment
    },
    var.extra_tags
  )
}
