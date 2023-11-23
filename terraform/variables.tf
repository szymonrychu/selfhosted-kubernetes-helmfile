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

variable "jupyterhub_client_secret" {
  description = "Client secret for 'jupyterhub' client"
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
}

variable "admin_user_password" {
  description = "Password of the 1st user in keycloak"
  type        = string
  nullable    = false
}
