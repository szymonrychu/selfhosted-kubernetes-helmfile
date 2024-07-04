terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">=4.3.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">=4.9.0"
    }
    grafana = {
      source  = "grafana/grafana"
      version = ">=1.28.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.30.0"
    }
  }
}

terraform {
  required_version = ">= 1.8"
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

provider "kubernetes" {
}

provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_api_key
}
