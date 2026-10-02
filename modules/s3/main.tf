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

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.bucket
  acl    = local.acl_type
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

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  depends_on = [aws_s3_bucket_versioning.this]
  count      = length(var.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.bucket
  #TODO: Finish this
}
