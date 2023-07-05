terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">=4.3.1"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = var.admin_user_username
  password  = var.admin_user_password
  url       = var.keycloak_url
}