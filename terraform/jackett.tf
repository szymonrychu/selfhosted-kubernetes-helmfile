locals {
  jackett_root_url = "https://jackett.szymonrichert.pl"
}

resource "keycloak_openid_client" "jackett" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Jackett"
  client_id     = "jackett"
  client_secret = var.jackett_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.jackett_root_url
  admin_url = local.jackett_root_url
  base_url  = local.jackett_root_url
  valid_redirect_uris = [
    "${local.jackett_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "jackett_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.jackett.id
  name      = "aud"

  # included_custom_audience = "jackett"
  included_client_audience = "jackett"
}

resource "keycloak_openid_client_default_scopes" "jackett" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.jackett.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "jackett" {
  realm_id = data.keycloak_realm.master.id
  name     = "jackett"
}
