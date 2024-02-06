terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">=4.3.1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = ">=3.12.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.9.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.admin_user_username
  password  = var.admin_user_password
  url       = var.keycloak_url
}