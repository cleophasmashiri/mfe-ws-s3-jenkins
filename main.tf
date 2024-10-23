# main.tf

resource "aws_s3_bucket_cors_configuration" "mfe_login_cors" {
  for_each = toset(var.bucket_names)

  bucket = each.value

  cors_rule {
    allowed_methods = ["GET"]  # Allow GET requests
    allowed_origins = ["*"]    # Or specify the specific domain of the Nx shell app, e.g., "http://shell-app-domain.com"
    allowed_headers = ["*"]    # Allow all headers or restrict it to specific headers
    expose_headers  = ["ETag"] # Optional, expose specific headers to the client
    max_age_seconds = 3000     # Cache preflight requests for 3000 seconds
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

  force_destroy = true

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
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${each.value.arn}/*"
      }
    ]
  })
}

resource "aws_lambda_function" "my_lambda_function" {
  filename      = "lambda_function.zip"
  function_name = "s3-file-reader"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# resource "aws_iam_role" "lambda_role" {
#   name = "lambda-execution-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Action    = "sts:AssumeRole"
#       Effect    = "Allow"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

resource "aws_iam_policy" "lambda_s3_policy" {

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:GetObject"
      ],
      Resource = "arn:aws:s3:::dashboard-2019/*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev_vp"
  }
}

resource "aws_subnet" "my_public_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1a"
  tags = {
    Name = "dev-public"
  }
}
resource "aws_subnet" "my_public_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-north-1b"
  tags = {
    Name = "dev-public2"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev_igw"
  }
}

resource "aws_route_table" "my_public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "dev_rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.my_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_vpc_igw.id
}

resource "aws_route_table_association" "my_public_assoc_1" {
  subnet_id      = aws_subnet.my_public_subnet_1.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_route_table_association" "my_public_assoc_2" {
  subnet_id      = aws_subnet.my_public_subnet_2.id
  route_table_id = aws_route_table.my_public_rt.id
}

resource "aws_security_group" "my_public_sec_gp" {
  # ... other configuration ...
  vpc_id      = aws_vpc.my_vpc.id
  description = "mtc security gp"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_public_sec_gp.id]
  # subnets            = aws_subnet.my_public_subnet[*].id
  subnets = [
    aws_subnet.my_public_subnet_1.id,
    aws_subnet.my_public_subnet_2.id
  ]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "lambda_target" {
  name        = "lambda-target"
  target_type = "lambda"

  health_check {
    enabled             = false
    interval            = 30 # The time between health checks (must be greater than timeout)
    timeout             = 5  # The time a health check has to complete
    healthy_threshold   = 3  # How many consecutive health checks a target must pass to be considered healthy
    unhealthy_threshold = 2  # How many consecutive health checks a target must fail to be considered unhealthy
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type               = "forward"
    target_group_arn   = aws_lb_target_group.lambda_target.arn
  }
}

# Attach the ALB target group to the Lambda Function
# resource "aws_lb_target_group_attachment" "target_group_attachment" {
#   target_group_arn = aws_lb_target_group.lambda_target.arn
#   target_id        = aws_lambda_function.my_lambda_function.arn
# }


resource "aws_lambda_permission" "allow_alb_invoke" {
  statement_id  = "AllowALBInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "elasticloadbalancing.amazonaws.com"
  # principal     = "ecs-tasks.amazonaws.com"
  source_arn    = aws_lb_target_group.lambda_target.arn
}



resource "aws_cloudfront_distribution" "my_cloudfront" {
  origin {
    domain_name = aws_lb.my_alb.dns_name   # Set ALB DNS as the origin
    origin_id   = "my-alb-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  # Could also be "https-only" or "match-viewer"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]  # Specify the allowed SSL protocols
    }
  }

  enabled             = true
  default_root_object = "index.html"

  # Cache behavior
  default_cache_behavior {
    target_origin_id       = "my-alb-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Optional - SSL configuration
  viewer_certificate {
    cloudfront_default_certificate = true # Use default CloudFront SSL certificate
    # To use your custom SSL, you can reference your ACM certificate here
    # acm_certificate_arn = aws_acm_certificate.cert.arn
    # ssl_support_method   = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Logging for CloudFront
  # logging_config {
  #   include_cookies = false
  #   bucket          = aws_s3_bucket.cloudfront_logs.bucket
  #   prefix          = "cf-logs/"
  # }

  tags = {
    Name = "My-CloudFront-Distribution"
  }
}





