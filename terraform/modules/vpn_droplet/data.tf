data "digitalocean_image" "this" {
  slug = "ubuntu-22-04-x64"
}

data "digitalocean_sizes" "this" {
  filter {
    key    = "vcpus"
    values = [1]
  }

  filter {
    key    = "regions"
    values = [data.digitalocean_region.this.slug]
  }

  sort {
    key       = "price_monthly"
    direction = "asc"
  }
}

data "digitalocean_region" "this" {
  slug = var.droplet_region
}