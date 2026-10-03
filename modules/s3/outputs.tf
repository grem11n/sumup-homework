output "bucket_name" {
  description = "Bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_acl" {
  description = "Access type of the bucket"
  value       = aws_s3_bucket_acl.this.acl
}
