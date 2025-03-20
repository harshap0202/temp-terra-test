output "bucket_name" {
  value = module.s3-rdm-ui.bucket_name
}

output "cloudfront" {
  value = module.cloudfront-rdm-ui.domain_name
}

output "domain_details" {
  value = module.cloudfront-rdm-ui.domain_details
}