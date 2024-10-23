terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region                   = "eu-north-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}

# provider "aws" {
#     region = "eu-north-1"
#     # only required for non virtual hosted-style endpoint use case.
#     # https://registry.terraform.io/providers/hashicorp/aws/latest/docs#s3_force_path_style
#     s3_use_path_style = false
#     skip_credentials_validation = true
#     skip_metadata_api_check = true
#     skip_requesting_account_id = true

#     # endpoints {
#     #  s3 = "https://s3.eu-north-1.amazonaws.com"
#     # }
#   }