module "vpn_droplet" {
  source = "./modules/vpn_droplet"

  digitalocean_token = var.digitalocean_token
  ssh_priv_path      = pathexpand("~/.ssh/id_rsa")
  ssh_pub_path       = pathexpand("~/.ssh/id_rsa.pub")
  droplet_name       = "vpn"
  droplet_region     = "ams3"
}