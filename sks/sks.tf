terraform {
  backend "s3" {
    bucket = "bucket-tfstates"
    key = "terraform.tfstate"
    region = "ch-gva-2"
    endpoint = "sos-ch-gva-2.exo.io"
    skip_credentials_validation = true
    skip_region_validation = true
  }
}


module "sks" {
  source  = "camptocamp/sks/exoscale"
  version = "0.4.1"

  name = "lfs2023"
  zone = "ch-gva-2"
  kubernetes_version = "1.24.12"

  nodepools = {
    "compute" = {
      instance_type = "standard.medium"
      size          = 3
    },
  }
}

output "kubeconfig" {
  value     = module.sks.kubeconfig
  sensitive = true
}
