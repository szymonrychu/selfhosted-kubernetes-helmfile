module "bazarr" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "bazarr"
  keycloak_client_name     = "Bazarr"
  keycloak_client_hostname = "bazarr.szymonrichert.pl"
  keycloak_group_name      = "bazarr"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "code-server" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "code-server"
  keycloak_client_name     = "Code Server"
  keycloak_client_hostname = "code.szymonrichert.pl"
  keycloak_group_name      = "code-server"

  kubernetes_secret_namespace = "code-server"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "esphome" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "esphome"
  keycloak_client_name     = "ESP Home"
  keycloak_client_hostname = "esphome.szymonrichert.pl"
  keycloak_group_name      = "home-automation"

  kubernetes_secret_namespace = "home-automation"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "files" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "files"
  keycloak_client_name     = "Files"
  keycloak_client_hostname = "files.szymonrichert.pl"
  keycloak_group_name      = "files"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "prowlarr" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "prowlarr"
  keycloak_client_name     = "Prowlarr"
  keycloak_client_hostname = "prowlarr.szymonrichert.pl"
  keycloak_group_name      = "prowlarr"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "qbittorrent" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "qbittorrent"
  keycloak_client_name     = "QBittorrent"
  keycloak_client_hostname = "qbt.szymonrichert.pl"
  keycloak_group_name      = "qbittorrent"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "radarr" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "radarr"
  keycloak_client_name     = "Radarr"
  keycloak_client_hostname = "radarr.szymonrichert.pl"
  keycloak_group_name      = "radarr"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "sonarr" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "sonarr"
  keycloak_client_name     = "Sonarr"
  keycloak_client_hostname = "sonarr.szymonrichert.pl"
  keycloak_group_name      = "sonarr"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "unmanic" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "unmanic"
  keycloak_client_name     = "Unmanic"
  keycloak_client_hostname = "unmanic.szymonrichert.pl"
  keycloak_group_name      = "unmanic"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "lidarr" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "lidarr"
  keycloak_client_name     = "Bitmagnet"
  keycloak_client_hostname = "lidarr.szymonrichert.pl"
  keycloak_group_name      = "lidarr"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}

module "bitmagnet" {
  source = "github.com/szymonrychu/oauth2-proxy-admission-controller.git//terraform_keycloak_client?ref=0.1.8"

  keycloak_url             = var.keycloak_url
  keycloak_client_id       = "bitmagnet"
  keycloak_client_name     = "bitmagnet"
  keycloak_client_hostname = "bitmagnet.szymonrichert.pl"
  keycloak_group_name      = "bitmagnet"

  kubernetes_secret_namespace = "media"

  kuberenetes_proxy_cookie_secret = var.kuberenetes_proxy_cookie_secret

  keycloak_openid_client_scope_name = keycloak_openid_client_scope.groups.name
}
