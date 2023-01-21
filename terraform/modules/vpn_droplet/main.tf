resource "digitalocean_ssh_key" "default" {
  name       = "main_SSH_key"
  public_key = file(var.ssh_pub_path)
}

resource "digitalocean_droplet" "this" {
  image     = data.digitalocean_image.this.id
  name      = var.droplet_name
  region    = data.digitalocean_region.this.slug
  size      = element(data.digitalocean_sizes.this.sizes, 0).slug
  ssh_keys  = [digitalocean_ssh_key.default.fingerprint]

  connection {
    host = self.ipv4_address
    user = "root"
    type = "ssh"
    private_key = file(var.ssh_priv_path)
    timeout = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt update",
      "sudo apt install -y nginx"
    ]
  }

}