provider "aws" {
  region  = var.region
}

resource "aws_s3_bucket" "react-bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name      = "${var.prefix}-s3-bucket"
    Terraform = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "access" {
  bucket = aws_s3_bucket.react-bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# acm =======================================================================================

provider "aws" {
  alias   = "acm"  
  region  = "us-east-1" # us-east-1 region for acm 
  profile = "harsh"
}

resource "aws_acm_certificate" "rdm_ui_certificate" {
  provider          = aws.acm 
  domain_name       = var.domain_name
  validation_method = "DNS"  

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name      = "${var.prefix}-certificate"
    Terraform = "true"

  }
}

# oac =======================================================================================

resource "aws_cloudfront_origin_access_control" "new-oac" {
  name                              = aws_s3_bucket.react-bucket.id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

data "aws_cloudfront_cache_policy" "CachingDisabled" {
  name = "Managed-CachingDisabled"
}

# cloudfront ================================================================================

resource "aws_cloudfront_distribution" "cloudfront" {
  default_root_object = "index.html"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  enabled             = true

  origin {
    origin_id                = aws_s3_bucket.react-bucket.id
    origin_access_control_id = aws_cloudfront_origin_access_control.new-oac.id
    domain_name              = aws_s3_bucket.react-bucket.id
  }

  default_cache_behavior {
    cache_policy_id  = data.aws_cloudfront_cache_policy.CachingDisabled.id
    target_origin_id = aws_s3_bucket.react-bucket.id
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    compress         = true

    viewer_protocol_policy = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = [
    var.domain_name
  ]

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.rdm_ui_certificate.arn
    minimum_protocol_version       = "TLSv1.2_2021" 
    ssl_support_method             = "sni-only"
  }

  tags = {
    Name      = "${var.prefix}-cloudfront-distribution"
    Terraform = "true"
  }
  
  provisioner "local-exec" {
    command = "aws cloudfront create-invalidation --distribution-id ${self.id} --paths '/*' --profile='harsh'"
  }
}

# s3 policy ================================================================================

data "aws_iam_policy_document" "iam-policy-1" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions = ["s3:GetObject"]
    resources = [
      "${aws_s3_bucket.react-bucket.arn}/*",
    ]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.cloudfront.arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.iam-policy-1.json
}


