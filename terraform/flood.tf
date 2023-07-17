locals {
  flood_root_url = "https://flood.szymonrichert.pl"
}

resource "keycloak_openid_client" "flood" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Flood"
  client_id     = "flood"
  client_secret = var.flood_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.flood_root_url
  admin_url = local.flood_root_url
  base_url  = local.flood_root_url
  valid_redirect_uris = [
    "${local.flood_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.flood.id
  name      = "aud"

  # included_custom_audience = "flood"
  included_client_audience = "flood"
}

resource "keycloak_openid_client_default_scopes" "flood" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.flood.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "flood" {
  realm_id = data.keycloak_realm.master.id
  name     = "flood"
}

