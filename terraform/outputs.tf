output "s3_bucket_arn" {
  value       = aws_s3_bucket.demo.arn
  description = "ARN of the main S3 bucket"
}

output "vpc_id" {
  value = aws_vpc.demo.id
}

output "security_group_id" {
  value = aws_security_group.demo.id
}
