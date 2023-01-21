variable "digitalocean_token" {
  type        = string
  description = "Token to digitialocean API"
}

variable "ssh_priv_path" {
  type        = string
  description = "Path to SSH key that will be used to login to droplet"
}

variable "ssh_pub_path" {
  type        = string
  description = "Path to SSH pub that will be used to login to droplet"
}

variable "droplet_name" {
  type        = string
  description = "Name of the droplet"
}

variable "droplet_region" {
  type        = string
  description = "Region for the droplet"
}