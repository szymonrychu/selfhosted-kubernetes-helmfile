locals {
  code-server_root_url = "https://code.szymonrichert.pl"
}

resource "keycloak_openid_client" "code-server" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Code Server"
  client_id     = "code-server"
  client_secret = var.code_server_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.code-server_root_url
  admin_url = local.code-server_root_url
  base_url  = local.code-server_root_url
  valid_redirect_uris = [
    "${local.code-server_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "code-server_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.code-server.id
  name      = "aud"

  # included_custom_audience = "code-server"
  included_client_audience = "code-server"
}

resource "keycloak_openid_client_default_scopes" "code-server" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.code-server.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "code-server" {
  realm_id = data.keycloak_realm.master.id
  name     = "code-server"
}
