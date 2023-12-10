output "grafana_client_id" {
  description = "'grafana' client id"
  value       = keycloak_openid_client.grafana.client_id
  sensitive   = true
}

output "grafana_client_secret" {
  description = "'grafana' client secret"
  value       = keycloak_openid_client.grafana.client_secret
  sensitive   = true
}

output "qbittorrent_client_id" {
  description = "'qbittorrent' client id"
  value       = keycloak_openid_client.qbittorrent.client_id
  sensitive   = true
}

output "qbittorrent_client_secret" {
  description = "'qbittorrent' client secret"
  value       = keycloak_openid_client.qbittorrent.client_secret
  sensitive   = true
}

output "code_server_client_id" {
  description = "'code-server' client id"
  value       = keycloak_openid_client.code-server.client_id
  sensitive   = true
}

output "code_server_client_secret" {
  description = "'code-server' client secret"
  value       = keycloak_openid_client.qbittorrent.client_secret
  sensitive   = true
}

output "esphome_client_id" {
  description = "'esphome' client id"
  value       = keycloak_openid_client.esphome.client_id
  sensitive   = true
}

output "esphome_client_secret" {
  description = "'esphome' client secret"
  value       = keycloak_openid_client.esphome.client_secret
  sensitive   = true
}
