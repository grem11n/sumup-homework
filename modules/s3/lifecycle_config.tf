# This is almost a carbon copy of the lifecycle_configuration from Anton Babenko's module
# https://github.com/terraform-aws-modules/terraform-aws-s3-bucket/blob/master/main.tf#L352
# There are a lot of moving parts in the lifecycle rules, hence many dynamic blocks and a lot
# of code, but I think it is important to allow users to manage the lifecycle rules, otherwise
# S3 costs may go out of hand. Yet, it's hard to manage these rules in a centralized fashion
# because Platform teams do not necessarily know the data governance policies of a particular team
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]
  count      = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled != null ? (rule.value.enabled ? "Enabled" : "Disabled") : try(tobool(rule.value.status) ? "Enabled" : "Disabled", title(lower(rule.value.status)))

      # Max 1 block - abort_incomplete_multipart_upload
      dynamic "abort_incomplete_multipart_upload" {
        for_each = rule.value.abort_incomplete_multipart_upload_days != null ? [rule.value.abort_incomplete_multipart_upload_days] : []

        content {
          days_after_initiation = abort_incomplete_multipart_upload.value
        }
      }


      # Max 1 block - expiration
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []

        content {
          date                         = expiration.value.date
          days                         = expiration.value.days
          expired_object_delete_marker = expiration.value.expired_object_delete_marker
        }
      }

      # Several blocks - transition
      dynamic "transition" {
        for_each = rule.value.transition

        content {
          date          = transition.value.date
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Max 1 block - noncurrent_version_expiration
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          newer_noncurrent_versions = noncurrent_version_expiration.value.newer_noncurrent_versions
          noncurrent_days           = noncurrent_version_expiration.value.days != null ? noncurrent_version_expiration.value.days : noncurrent_version_expiration.value.noncurrent_days
        }
      }

      # Several blocks - noncurrent_version_transition
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transition

        content {
          newer_noncurrent_versions = noncurrent_version_transition.value.newer_noncurrent_versions
          noncurrent_days           = noncurrent_version_transition.value.days != null ? noncurrent_version_transition.value.days : noncurrent_version_transition.value.noncurrent_days
          storage_class             = noncurrent_version_transition.value.storage_class
        }
      }

      # Max 1 block - filter - without any key arguments or tags
      dynamic "filter" {
        for_each = rule.value.filter == null || max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 0 ? [true] : []

        content {
          #          prefix = ""
        }
      }

      # Max 1 block - filter - with one key argument or a single tag
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) == 1 ? [rule.value.filter] : []

        content {
          object_size_greater_than = filter.value.object_size_greater_than
          object_size_less_than    = filter.value.object_size_less_than
          prefix                   = filter.value.prefix

          dynamic "tag" {
            for_each = filter.value.tags != null ? filter.value.tags : filter.value.tag != null ? filter.value.tag : {}

            content {
              key   = tag.key
              value = tag.value
            }
          }
        }
      }

      # Max 1 block - filter - with more than one key arguments or multiple tags
      dynamic "filter" {
        for_each = rule.value.filter != null && max(
          length([for k, a in {
            object_size_greater_than = rule.value.filter.object_size_greater_than
            object_size_less_than    = rule.value.filter.object_size_less_than
            prefix                   = rule.value.filter.prefix
            tags                     = rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag
          } : k if a != null]),
          length(rule.value.filter.tags != null ? rule.value.filter.tags : rule.value.filter.tag != null ? rule.value.filter.tag : {})
        ) > 1 ? [rule.value.filter] : []

        content {
          and {
            object_size_greater_than = filter.value.object_size_greater_than
            object_size_less_than    = filter.value.object_size_less_than
            prefix                   = filter.value.prefix
            tags                     = filter.value.tags != null ? filter.value.tags : filter.value.tag
          }
        }
      }
    }
  }
}
