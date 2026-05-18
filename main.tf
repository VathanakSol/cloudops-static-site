provider "aws" {
    region = "ap-southeast-1"
}

resource "aws_s3_bucket" "website" {
    bucket = "cloudops-static-site-011543303027"
}

resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}

# Upload files from ./website
resource "aws_s3_object" "files" {
  for_each = fileset("${path.module}/website", "**/*")
  bucket   = aws_s3_bucket.website.bucket
  key      = each.value
  source   = "${path.module}/website/${each.value}"
  etag     = filemd5("${path.module}/website/${each.value}")
}