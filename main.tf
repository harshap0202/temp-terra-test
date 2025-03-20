provider "aws" {
  region  = var.region
  profile = "harsh"
}

# s3
module "s3-rdm-ui" {
  source      = "./modules/s3-rdm-ui"
  bucket_name = var.bucket_name
  prefix      = var.prefix
}

# cloudfront / OAC / Bucket Policy
module "cloudfront-rdm-ui" {
  source             = "./modules/cloudfront-rdm-ui"
  prefix             = var.prefix
  bucket_domain_name = module.s3-rdm-ui.bucket_domain_name
  bucket_arn         = module.s3-rdm-ui.bucket_arn
  bucket_name        = module.s3-rdm-ui.bucket_name
  domain_name        = var.domain_name
}

