data "keycloak_user" "admin" {
  realm_id = data.keycloak_realm.master.id
  username = var.admin_user_username
}

resource "keycloak_user_groups" "user_groups" {
  realm_id = data.keycloak_realm.master.id
  user_id  = data.keycloak_user.admin.id

  group_ids = [
    keycloak_group.grafana_admin.id,
    module.bazarr.keycloak_group_id,
    module.code-server.keycloak_group_id,
    module.esphome.keycloak_group_id,
    module.files.keycloak_group_id,
    module.prowlarr.keycloak_group_id,
    module.qbittorrent.keycloak_group_id,
    module.radarr.keycloak_group_id,
    module.tdarr.keycloak_group_id,
    module.sonarr.keycloak_group_id
  ]
}
