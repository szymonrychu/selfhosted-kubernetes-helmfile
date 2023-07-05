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