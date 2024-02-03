locals {
  esphome_root_url = "https://esphome.szymonrichert.pl"
}

resource "keycloak_openid_client" "esphome" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Esphome"
  client_id     = "esphome"
  client_secret = var.esphome_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.esphome_root_url
  admin_url = local.esphome_root_url
  base_url  = local.esphome_root_url
  valid_redirect_uris = [
    "${local.esphome_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "esphome_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.esphome.id
  name      = "aud"

  # included_custom_audience = "esphome"
  included_client_audience = "esphome"
}

resource "keycloak_openid_client_default_scopes" "esphome" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.esphome.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "esphome" {
  realm_id = data.keycloak_realm.master.id
  name     = "esphome"
}
