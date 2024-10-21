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

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "flux-system-0" {
  for_each = data.kustomization_build.flux-system.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )
}

# then loop through resources in ids_prio[1]
# and set an explicit depends_on on kustomization_resource.p0
# wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "flux-system-1" {
  for_each = data.kustomization_build.flux-system.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )
  
  wait = true
  
  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [ kustomization_resource.flux-system-0 ]
}

# finally, loop through resources in ids_prio[2]
# and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "flux-system-2" {
  for_each = data.kustomization_build.flux-system.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )

  depends_on = [ kustomization_resource.flux-system-1 ]
}
