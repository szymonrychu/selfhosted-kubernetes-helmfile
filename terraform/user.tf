data "keycloak_user" "admin" {
  realm_id = data.keycloak_realm.master.id
  username = var.admin_user_username
}

resource "keycloak_user_groups" "user_groups" {
  realm_id = data.keycloak_realm.master.id
  user_id  = data.keycloak_user.admin.id

  group_ids = [
    keycloak_group.bazarr.id,
    keycloak_group.grafana_admin.id,
    keycloak_group.code-server.id,
    keycloak_group.esphome.id,
    keycloak_group.files.id,
    keycloak_group.prowlarr.id,
    keycloak_group.qbittorrent.id,
    keycloak_group.radarr.id,
    keycloak_group.tdarr.id,
    keycloak_group.sonarr.id
  ]
}
