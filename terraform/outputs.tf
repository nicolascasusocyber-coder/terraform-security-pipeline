output "s3_bucket_arn" {
  value       = aws_s3_bucket.insecure_bucket.arn
  description = "ARN of the main S3 bucket"
}
