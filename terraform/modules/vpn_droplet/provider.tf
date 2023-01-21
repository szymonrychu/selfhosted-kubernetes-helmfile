terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.25.2"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}