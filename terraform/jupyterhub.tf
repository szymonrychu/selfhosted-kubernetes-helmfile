locals {
  jupyterhub_root_url = "https://jupyterhub.szymonrichert.pl"
}

resource "keycloak_openid_client" "jupyterhub" {
  realm_id    = data.keycloak_realm.master.id
  access_type = "CONFIDENTIAL"
  login_theme = "keycloak"

  name          = "Jupyterhub"
  client_id     = "jupyterhub"
  client_secret = var.jupyterhub_client_secret

  enabled                      = true
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = true

  root_url  = local.jupyterhub_root_url
  admin_url = local.jupyterhub_root_url
  base_url  = local.jupyterhub_root_url
  valid_redirect_uris = [
    "${local.jupyterhub_root_url}/*"
  ]
}

resource "keycloak_openid_audience_protocol_mapper" "jupyterhub_audience_mapper" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.jupyterhub.id
  name      = "aud"

  # included_custom_audience = "jupyterhub"
  included_client_audience = "jupyterhub"
}

resource "keycloak_openid_client_default_scopes" "jupyterhub" {
  realm_id  = data.keycloak_realm.master.id
  client_id = keycloak_openid_client.jupyterhub.id
  default_scopes = [
    "profile",
    "email",
    "aud",
    keycloak_openid_client_scope.groups.name,
    keycloak_openid_client_scope.groups.name,
  ]
}

resource "keycloak_group" "jupyterhub" {
  realm_id = data.keycloak_realm.master.id
  name     = "jupyterhub"
}

