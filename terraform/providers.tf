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
  config_path    = "~/.kube/config"
  config_context = "kubernetes-admin@kubernetes"
}

provider "grafana" {
  url  = var.grafana_url
  auth = var.grafana_api_key
}
