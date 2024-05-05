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

output "files_client_id" {
  description = "'files' client id"
  value       = keycloak_openid_client.files.client_id
  sensitive   = true
}

output "files_client_secret" {
  description = "'files' client secret"
  value       = keycloak_openid_client.files.client_secret
  sensitive   = true
}

output "radarr_client_id" {
  description = "'radarr' client id"
  value       = keycloak_openid_client.radarr.client_id
  sensitive   = true
}

output "radarr_client_secret" {
  description = "'radarr' client secret"
  value       = keycloak_openid_client.radarr.client_secret
  sensitive   = true
}

output "sonarr_client_id" {
  description = "'sonarr' client id"
  value       = keycloak_openid_client.sonarr.client_id
  sensitive   = true
}

output "sonarr_client_secret" {
  description = "'sonarr' client secret"
  value       = keycloak_openid_client.sonarr.client_secret
  sensitive   = true
}

output "prowlarr_client_id" {
  description = "'prowlarr' client id"
  value       = keycloak_openid_client.prowlarr.client_id
  sensitive   = true
}

output "prowlarr_client_secret" {
  description = "'prowlarr' client secret"
  value       = keycloak_openid_client.prowlarr.client_secret
  sensitive   = true
}

output "bazarr_client_id" {
  description = "'bazarr' client id"
  value       = keycloak_openid_client.bazarr.client_id
  sensitive   = true
}

output "bazarr_client_secret" {
  description = "'bazarr' client secret"
  value       = keycloak_openid_client.bazarr.client_secret
  sensitive   = true
}

output "code_server_client_id" {
  description = "'code-server' client id"
  value       = keycloak_openid_client.code-server.client_id
  sensitive   = true
}

output "code_server_client_secret" {
  description = "'code-server' client secret"
  value       = keycloak_openid_client.code-server.client_secret
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
