
output "s3_bucket_names" {
  description = "The names of the created S3 buckets"
  value       = [for bucket in aws_s3_bucket.multiple_buckets: bucket.bucket]
}

output "s3_bucket_websites" {
  description = "The static website endpoints of the S3 buckets"
  value       = { for name, bucket in aws_s3_bucket.multiple_buckets : name => bucket.website_endpoint }
}

