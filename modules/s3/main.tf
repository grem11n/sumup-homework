resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
  tags   = local.merged_tags
}

resource "aws_s3_bucket_abac" "this" {
  bucket = aws_s3_bucket.this.bucket
  abac_status {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.bucket
  rule {
    object_ownership = local.object_ownership
  }
}

# This is a bit of a naive implementation. In reality, access block may look different,
# especially if we want to allow cross-account access to a private bucket
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.bucket

  block_public_acls       = var.access == "private" ? true : false
  block_public_policy     = var.access == "private" ? true : false
  ignore_public_acls      = var.access == "private" ? true : false
  restrict_public_buckets = var.access == "private" ? true : false
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this.bucket
  acl    = local.acl_type
}

# Using the default AWS key and AES256 encryption here as an example. In reality, you likely would
# want to use bucket KMS keys here
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = "aws/s3"
      sse_algorithm     = "AES256"
    }
  }
}

# I am not sure if there are cases when you don't want to have versioning enalbed,
# so hardcoding it
# Also, no test for it, because it doesn't make sense to test hardcode
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.bucket
  versioning_configuration {
    status = "Enabled"
  }
}
