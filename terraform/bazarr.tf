locals {
  bazarr_root_url = "https://bazarr.szymonrichert.pl"
}

resource "keycloak_openid_client" "bazarr" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Bazarr"
  client_id     = "bazarr"
  client_secret = var.bazarr_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.bazarr_root_url
  admin_url = local.bazarr_root_url
  base_url  = local.bazarr_root_url
  valid_redirect_uris = [
    "${local.bazarr_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "bazarr_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.bazarr.id
  name      = "aud"

  # included_custom_audience = "bazarr"
  included_client_audience = "bazarr"
}

resource "keycloak_openid_client_default_scopes" "bazarr" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.bazarr.id
  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "bazarr" {
  realm_id = data.keycloak_realm.master.id
  name     = "bazarr"
}
