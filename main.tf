#terraform {
#  backend "gcs" {
#    bucket  = "kind-secret"
#    prefix  = "terraform/state"
#  }
#}

module "github_repository" {
  source                   = "github.com/DpaHbaLT/tf-google-gke-cluster"
  github_owner             = var.GITHUB_OWNER
  github_token             = var.GITHUB_TOKEN
  repository_name          = var.FLUX_GITHUB_REPO
  public_key_openssh       = module.tls_private_key.public_key_openssh
  public_key_openssh_title = "flux"
}

module "tls_private_key" {
  source    = "github.com/DpaHbaLT/tf-hashicorp-tls-keys"
  algorithm = "RSA"
}

# Source: "github.com/den-vasyliev/tf-kind-cluster?ref=cert_auth"
module "kind_cluster" {
  source = "github.com/den-vasyliev/tf-kind-cluster?ref=cert_auth"
}

# # Source: "github.com/den-vasyliev/tf-fluxcd-flux-bootstrap?ref=kind_auth"
module "flux_bootstrap" {
  source            = "./modules/flux_bootstrap/"
  github_repository = "${var.GITHUB_OWNER}/${var.FLUX_GITHUB_REPO}"
  private_key       = module.tls_private_key.private_key_pem
  config_host       = module.kind_cluster.endpoint
  config_client_key = module.kind_cluster.client_key
  config_ca         = module.kind_cluster.ca
  config_crt        = module.kind_cluster.crt
  github_token      = var.GITHUB_TOKEN
}


