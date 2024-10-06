provider "aws" {
    region = var.aws_region
    secret_key = "test"
    # only required for non virtual hosted-style endpoint use case.
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_force_path_style
    s3_use_path_style = false
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true
  
    endpoints {
      s3 = "http://192.168.0.210:4566"
    }
  }