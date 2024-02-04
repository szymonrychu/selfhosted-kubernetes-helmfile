locals {
  qbittorrent_root_url = "https://qbt.szymonrichert.pl"
}

resource "keycloak_openid_client" "qbittorrent" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Qbittorrent"
  client_id     = "qbittorrent"
  client_secret = var.qbittorrent_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.qbittorrent_root_url
  admin_url = local.qbittorrent_root_url
  base_url  = local.qbittorrent_root_url
  valid_redirect_uris = [
    "${local.qbittorrent_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "qbittorrent_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.qbittorrent.id
  name      = "aud"

  # included_custom_audience = "qbittorrent"
  included_client_audience = "qbittorrent"
}

resource "keycloak_openid_client_default_scopes" "qbittorrent" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.qbittorrent.id
  default_scopes = [
    "profile",
    "email",
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "qbittorrent" {
  realm_id = data.keycloak_realm.master.id
  name     = "qbittorrent"
}
