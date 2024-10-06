variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "eu-north-1"
}

variable "bucket_names" {
  description = "List of S3 bucket names to create"
  type        = list(string)
  default     = ["dashboard"]
}
