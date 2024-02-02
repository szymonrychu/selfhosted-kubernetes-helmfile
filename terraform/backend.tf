terraform {
  backend "s3" {
    bucket = "szymonrychu-terraform-state"
    key    = "selfhosted-kubernetes-helmfile"
    region = "eu-west-1"
  }
}
