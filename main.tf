# main.tf

resource "aws_s3_bucket_cors_configuration" "mfe_login_cors" {
  for_each = toset(var.bucket_names)

  bucket = each.value

  cors_rule {
    allowed_methods = ["GET"]           # Allow GET requests
    allowed_origins = ["*"]             # Or specify the specific domain of the Nx shell app, e.g., "http://shell-app-domain.com"
    allowed_headers = ["*"]             # Allow all headers or restrict it to specific headers
    expose_headers  = ["ETag"]          # Optional, expose specific headers to the client
    max_age_seconds = 3000              # Cache preflight requests for 3000 seconds
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  for_each = toset(var.bucket_names)

  bucket = each.value

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "multiple_buckets" {
  for_each = toset(var.bucket_names)

  bucket = each.key

  # Enable versioning (optional)
  versioning {
    enabled = true
  }

  # Enable static website hosting
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Name        = each.key
    Environment = "Dev"
  }
}

# Apply bucket policy to allow public read access for the static website
resource "aws_s3_bucket_policy" "bucket_policy" {
  for_each = aws_s3_bucket.multiple_buckets

  bucket = each.key

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = "*"
        Action = "s3:GetObject"
        Resource = "${each.value.arn}/*"
      }
    ]
  })
}