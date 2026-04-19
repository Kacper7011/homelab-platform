terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket = "terraform"
    key = "vault/terraform.tfstate"
    region = "us-east-1"
    endpoint = "http://10.10.10.115:9020"
    skip_credentials_validation = true
    skip_metadata_api_check = true
    skip_requesting_account_id = true
    force_path_style = true
  }
}

provider "vault" {
  address = var.vault_address
  token = var.root_token
}