# S3 Bucket for hosting website
resource "aws_s3_bucket" "web" {
  bucket = "pranav-web-bucket-20251002"
  tags   = { Name = "pranav-web-bucket" }
}

# Block all public access (we’ll serve via CloudFront later)
resource "aws_s3_bucket_public_access_block" "web_block" {
  bucket = aws_s3_bucket.web.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}

# S3 Bucket for uploaded files
resource "aws_s3_bucket" "files" {
  bucket = "pranav-files-bucket-20251002"
  tags   = { Name = "pranav-files-bucket" }
}

resource "aws_s3_bucket_public_access_block" "files_block" {
  bucket = aws_s3_bucket.files.id

  block_public_acls   = true
  ignore_public_acls  = true
  block_public_policy = true
  restrict_public_buckets = true
}

# DynamoDB table for file metadata
resource "aws_dynamodb_table" "files_meta" {
  name         = "pranav-files-meta"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "fileId"

  attribute {
    name = "fileId"
    type = "S"
  }

  tags = {
    Name = "pranav-files-meta"
  }
}

# Outputs
output "web_bucket" {
  value = aws_s3_bucket.web.bucket
}
output "files_bucket" {
  value = aws_s3_bucket.files.bucket
}
output "files_table" {
  value = aws_dynamodb_table.files_meta.name
}
