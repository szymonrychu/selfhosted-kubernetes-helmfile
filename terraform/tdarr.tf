locals {
  tdarr_root_url = "https://tdarr.szymonrichert.pl"
}

resource "keycloak_openid_client" "tdarr" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Tadarr"
  client_id     = "tdarr"
  client_secret = var.tdarr_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.tdarr_root_url
  admin_url = local.tdarr_root_url
  base_url  = local.tdarr_root_url
  valid_redirect_uris = [
    "${local.tdarr_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "tdarr_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.tdarr.id
  name      = "aud"

  # included_custom_audience = "tdarr"
  included_client_audience = "tdarr"
}

resource "keycloak_openid_client_default_scopes" "tdarr" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.tdarr.id
  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "tdarr" {
  realm_id = data.keycloak_realm.master.id
  name     = "tdarr"
}
