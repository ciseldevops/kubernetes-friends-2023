module "sks" {
  source  = "camptocamp/sks/exoscale"
  version = "0.3.1"

  name = "lfs2023"
  zone = "ch-gva-2"

  nodepools = {
    "compute" = {
      instance_type = "small"
      size          = 3
    },
  }
}

output "kubeconfig" {
  value     = module.sks.kubeconfig
  sensitive = true
}
