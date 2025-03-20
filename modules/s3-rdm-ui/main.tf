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
