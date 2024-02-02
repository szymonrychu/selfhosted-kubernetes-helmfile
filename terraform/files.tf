locals {
  files_root_url = "https://files.szymonrichert.pl"
}

resource "keycloak_openid_client" "files" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Files"
  client_id     = "files"
  client_secret = var.files_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.files_root_url
  admin_url = local.files_root_url
  base_url  = local.files_root_url
  valid_redirect_uris = [
    "${local.files_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "files_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.files.id
  name      = "aud"

  # included_custom_audience = "files"
  included_client_audience = "files"
}

resource "keycloak_openid_client_default_scopes" "files" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.files.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "files" {
  realm_id = data.keycloak_realm.master.id
  name     = "files"
}
