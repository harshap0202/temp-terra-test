output "bucket_name" {
  value = aws_s3_bucket.react-bucket.id
}

output "domain_name" {
  value = aws_cloudfront_distribution.cloudfront.domain_name
}

output "domain_details" {
  value = aws_acm_certificate.rdm_ui_certificate.domain_validation_options
}