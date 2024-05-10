variable "grafana_client_secret" {
  description = "Client secret for 'grafana' client"
  type        = string
  default     = null
}

variable "qbittorrent_client_secret" {
  description = "Client secret for 'qbittorrent' client"
  type        = string
  default     = null
}

variable "files_client_secret" {
  description = "Client secret for 'files' client"
  type        = string
  default     = null
}

variable "radarr_client_secret" {
  description = "Client secret for 'radarr' client"
  type        = string
  default     = null
}

variable "tdarr_client_secret" {
  description = "Client secret for 'tdarr' client"
  type        = string
  default     = null
}

variable "sonarr_client_secret" {
  description = "Client secret for 'sonarr' client"
  type        = string
  default     = null
}

variable "prowlarr_client_secret" {
  description = "Client secret for 'prowlarr' client"
  type        = string
  default     = null
}

variable "bazarr_client_secret" {
  description = "Client secret for 'bazarr' client"
  type        = string
  default     = null
}

variable "code_server_client_secret" {
  description = "Client secret for 'code-server' client"
  type        = string
  default     = null
}

variable "esphome_client_secret" {
  description = "Client secret for 'esphome' client"
  type        = string
  default     = null
}

variable "keycloak_url" {
  description = "Url to keycloak"
  type        = string
  nullable    = false
}

variable "admin_user_username" {
  description = "Username of the 1st user in keycloak"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "admin_user_password" {
  description = "Password of the 1st user in keycloak"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "grafana_url" {
  description = "Url to grafana"
  type        = string
  nullable    = false
}

variable "grafana_api_key" {
  description = "API key for grafana"
  type        = string
  nullable    = false
  sensitive   = true
}

variable "kuberenetes_proxy_cookie_secret" {
  description = "Oauth2proxy cookie secret"
  type        = string
  nullable    = false
  sensitive   = true
}
