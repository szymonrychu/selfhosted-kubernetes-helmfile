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

output "flood_client_id" {
  description = "'flood' client id"
  value       = keycloak_openid_client.flood.client_id
  sensitive   = true
}

output "flood_client_secret" {
  description = "'flood' client secret"
  value       = keycloak_openid_client.flood.client_secret
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