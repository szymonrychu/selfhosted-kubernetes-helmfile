locals {
  sonarr_root_url = "https://sonarr.szymonrichert.pl"
}

resource "keycloak_openid_client" "sonarr" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Sonarr"
  client_id     = "sonarr"
  client_secret = var.sonarr_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.sonarr_root_url
  admin_url = local.sonarr_root_url
  base_url  = local.sonarr_root_url
  valid_redirect_uris = [
    "${local.sonarr_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "sonarr_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.sonarr.id
  name      = "aud"

  # included_custom_audience = "sonarr"
  included_client_audience = "sonarr"
}

resource "keycloak_openid_client_default_scopes" "sonarr" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.sonarr.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "sonarr" {
  realm_id = data.keycloak_realm.master.id
  name     = "sonarr"
}
