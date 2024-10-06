# main.tf

resource "aws_s3_bucket" "multiple_buckets" {
  for_each = toset(var.bucket_names)

  bucket = each.key
  force_destroy = true

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