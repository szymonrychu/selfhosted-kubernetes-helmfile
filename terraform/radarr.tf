locals {
  radarr_root_url = "https://radarr.szymonrichert.pl"
}

resource "keycloak_openid_client" "radarr" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Radarr"
  client_id     = "radarr"
  client_secret = var.radarr_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.radarr_root_url
  admin_url = local.radarr_root_url
  base_url  = local.radarr_root_url
  valid_redirect_uris = [
    "${local.radarr_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "radarr_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.radarr.id
  name      = "aud"

  # included_custom_audience = "radarr"
  included_client_audience = "radarr"
}

resource "keycloak_openid_client_default_scopes" "radarr" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.radarr.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "radarr" {
  realm_id = data.keycloak_realm.master.id
  name     = "radarr"
}
