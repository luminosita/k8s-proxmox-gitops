module "talos-image" {
  source = "../../terraform-generic-talos/talos-image"

  providers = {
    talos = talos
  }

  image = var.talos_image
}

module "proxmox-vm" {
  depends_on = [ module.talos-image ]

  source = "../../terraform-generic-talos/proxmox-vm"

  providers = {
    proxmox = proxmox
  }

  image = {
    file_name = module.talos-image.result.file_name
    file_name_update = module.talos-image.result.file_name_update
    url = module.talos-image.result.url
    url_update = module.talos-image.result.url_update

    proxmox_datastore = var.talos_image.proxmox_datastore
  }

  nodes = var.talos_nodes

  network = var.talos_cluster_config.network
}

module "talos-bootstrap" {
  depends_on = [ module.proxmox-vm ]

  source = "../../terraform-generic-talos/talos-bootstrap"

  providers = {
    talos = talos
  }

  cluster = var.talos_cluster_config

  nodes = var.talos_nodes
}

# module "sealed_secrets" {
#   depends_on = [module.talos-bootstrap]
#   source = "../../terraform-generic-talos/k8s-sealed-secrets"

#   providers = {
#     kubernetes = kubernetes
#   }

#   // openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout sealed-secrets.key -out sealed-secrets.cert -subj "/CN=sealed-secret/O=sealed-secret"
#   cert = {
#     cert = file("${path.module}/../config/certificate/sealed-secrets.cert")
#     key = file("${path.module}/../config/certificate/sealed-secrets.key")
#   }
# }

# module "gitops" {
#   depends_on = [module.talos-bootstrap]
#   source = "./gitops"

#   providers = {
#     kustomization = kustomization
#   }
# }

