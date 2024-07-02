terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">=1.28.2"
    }
  }
}

terraform {
  required_version = ">= 1.8"
}
