data "keycloak_user" "admin" {
  realm_id = data.keycloak_realm.master.id
  username = var.admin_user_username
}

resource "keycloak_user_groups" "user_groups" {
  realm_id = data.keycloak_realm.master.id
  user_id  = data.keycloak_user.admin.id

  group_ids = [
    keycloak_group.grafana_admin.id
  ]
}