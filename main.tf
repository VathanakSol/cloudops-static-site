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

resource "aws_s3_bucket_ownership_controls" "website" {
  bucket = aws_s3_bucket.website.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = false
  ignore_public_acls      = false
  block_public_policy     = false  
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket_ownership_controls.website]
}

resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id
  depends_on = [aws_s3_bucket_public_access_block.website]

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
locals {
  site_files = toset(flatten([
    fileset("${path.module}", "index.html"),
    fileset("${path.module}", "assets/**"),
    fileset("${path.module}", "pages/**"),
    fileset("${path.module}", "js/**"),
  ]))

  content_type_map = {
    html = "text/html"
    css  = "text/css"
    js   = "application/javascript"
    png  = "image/png"
    jpg  = "image/jpeg"
    jpeg = "image/jpeg"
    gif  = "image/gif"
    svg  = "image/svg+xml"
    ico  = "image/x-icon"
    json = "application/json"
    txt  = "text/plain"
  }
}

# Upload all site files and make them public
resource "aws_s3_object" "files" {
  for_each = { for f in local.site_files : f => f }
  bucket   = aws_s3_bucket.website.bucket

  key    = each.value
  source = "${path.module}/${each.value}"
  etag   = filemd5("${path.module}/${each.value}")
  acl    = "public-read"
  content_type = lookup(
    local.content_type_map,
    lower(try(regex(".*\\.([^.]+)$", each.value)[0], "")),
    "binary/octet-stream"
  )
}