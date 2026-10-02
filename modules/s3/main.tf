resource "aws_s3_bucket" "s3_bucket" {
  bucket = local.bucket_name
  tags   = local.merged_tags
}
