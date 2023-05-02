terraform {
  backend "s3" {
    bucket = "lfs-tfstates"
    key = "lfs-bucketstates"
    region = "ch-gva-2"
    endpoint = "sos-ch-gva-2.exo.io"
    #skip_credentials_validation = true
    #skip_region_validation = true
  }
}


module "sks" {
  source  = "camptocamp/sks/exoscale"
  version = "0.4.1"

  name = "flsdemo"
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
