locals {
  gateway = "192.168.50.1"

  talos_image = module.talos-image.result

  nodes = {
    "ctrl-gitops-00" = {
      host_node     = "proxmox"
      machine_type  = "controlplane"
      ip            = "192.168.50.120"
      mac_address   = "BC:24:11:2E:C8:05"
      vm_id         = 900
      cpu           = 4
      ram_dedicated = 2048
    }
    "work-gitops-00" = {
      host_node     = "proxmox"
      machine_type  = "worker"
      ip            = "192.168.50.125"
      mac_address   = "BC:24:11:2E:C8:06"
      vm_id         = 910
      cpu           = 4
      ram_dedicated = 4096
    }
  }
}

module "talos-image" {
  source = "../../terraform-generic-talos/talos-image"

  image = {
    version = "v1.7.6"
    update_version = "v1.7.6" # renovate: github-releases=siderolabs/talos
    name_prefix = "talos-gitops"
  }
}

module "proxmox" {
  depends_on = [ module.talos-image ]

  source = "./proxmox"

  providers = {
    proxmox = proxmox
  }

  image = module.talos-image.result

  nodes = local.nodes

  gateway = local.gateway
}

module "talos-bootstrap" {
  depends_on = [ module.proxmox ]

    source = "../../terraform-generic-talos/talos-bootstrap"

  cilium = {
    values = file("${path.module}/../config/cilium/values.yaml")
  }

  cluster = {
    name            = "talos-gitops"
    endpoint        = "192.168.50.120"
    gateway         = local.gateway
    talos_version   = "v1.8"
    proxmox_cluster = "proxmox"
  }

  nodes = local.nodes
}

module "sealed_secrets" {
  depends_on = [module.talos-bootstrap]
  source = "./bootstrap/sealed-secrets"

  providers = {
    kubernetes = kubernetes
  }

  // openssl req -x509 -days 365 -nodes -newkey rsa:4096 -keyout sealed-secrets.key -out sealed-secrets.cert -subj "/CN=sealed-secret/O=sealed-secret"
  cert = {
    cert = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.cert")
    key = file("${path.module}/bootstrap/sealed-secrets/certificate/sealed-secrets.key")
  }
}

data "kustomization_build" "flux-system" {
  path = "${path.module}/../k8s/infra/controllers/flux"
}

resource "kustomization_resource" "flux-system" {
  for_each = data.kustomization_build.flux-system.ids

  manifest = (
    data.kustomization_build.flux-system.manifests[each.value]
  )
}
