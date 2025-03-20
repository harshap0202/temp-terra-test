output "bucket_name" {
  value = aws_s3_bucket.react-bucket.id
}

output "bucket_domain_name" {
  value = aws_s3_bucket.react-bucket.bucket_regional_domain_name
}

output "bucket_arn" {
  value = aws_s3_bucket.react-bucket.arn
}