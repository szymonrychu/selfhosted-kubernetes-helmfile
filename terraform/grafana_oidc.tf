locals {
  grafana_root_url = "https://grafana.szymonrichert.pl"
}

resource "keycloak_openid_client" "grafana" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Grafana"
  client_id     = "grafana"
  client_secret = var.grafana_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.grafana_root_url
  admin_url = local.grafana_root_url
  base_url  = local.grafana_root_url
  valid_redirect_uris = [
    "${local.grafana_root_url}/*"
  ]

}

resource "keycloak_openid_client_default_scopes" "grafana" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.grafana.id
  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "grafana_admin" {
  realm_id = data.keycloak_realm.master.id
  name     = "grafana-admin"
}

resource "keycloak_group" "grafana_dev" {
  realm_id = data.keycloak_realm.master.id
  name     = "grafana-dev"
}


output "grafana_client_id" {
  value = keycloak_openid_client.grafana.client_id
}

output "grafana_client_secret" {
  value     = keycloak_openid_client.grafana.client_secret
  sensitive = true
}
