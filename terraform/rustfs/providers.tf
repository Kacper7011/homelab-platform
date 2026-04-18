terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }

    minio = {
        source  = "aminueza/minio"
        version = ">= 3.0.0"
    }
  }
  backend "s3" {
    bucket                      = "terraform"
    key                         = "rustfs/terraform.tfstate"
    region                      = "us-east-1"
    endpoint                    = "http://10.10.10.115:9020"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    force_path_style            = true
  }
}

provider "aws" {
  access_key = var.rustfs_access_key
  secret_key = var.rustfs_secret_key
  region = "us-east-1"

  endpoints {
    s3 = var.rustfs_address
  }

  skip_credentials_validation = true
  skip_metadata_api_check = true
  skip_requesting_account_id = true 
  s3_use_path_style = true
}

provider "minio" {
  minio_server = var.rustfs_host
  minio_user = var.rustfs_access_key
  minio_password = var.rustfs_secret_key
  minio_ssl = false
  s3_compat_mode = true
}