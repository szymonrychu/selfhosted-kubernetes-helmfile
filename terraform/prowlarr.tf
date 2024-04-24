locals {
  prowlarr_root_url = "https://prowlarr.szymonrichert.pl"
}

resource "keycloak_openid_client" "prowlarr" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Prowlarr"
  client_id     = "prowlarr"
  client_secret = var.prowlarr_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.prowlarr_root_url
  admin_url = local.prowlarr_root_url
  base_url  = local.prowlarr_root_url
  valid_redirect_uris = [
    "${local.prowlarr_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "prowlarr_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.prowlarr.id
  name      = "aud"

  # included_custom_audience = "prowlarr"
  included_client_audience = "prowlarr"
}

resource "keycloak_openid_client_default_scopes" "prowlarr" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.prowlarr.id
  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "prowlarr" {
  realm_id = data.keycloak_realm.master.id
  name     = "prowlarr"
}
