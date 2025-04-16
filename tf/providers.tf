terraform {
  required_version = ">= 1.9.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.75"
    }    
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.6"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure

  api_token = var.proxmox_api_token

  ssh {
    agent               = false
    username            = var.proxmox.ssh_username
    private_key         = file(var.proxmox.ssh_private_key_file)
  }
}

provider "kustomization" {
  kubeconfig_raw = module.talos-bootstrap.kube_config.kubeconfig_raw
}

provider "kubernetes" {
  host = module.talos-bootstrap.kube_config.kubernetes_client_configuration.host
  client_certificate = base64decode(module.talos-bootstrap.kube_config.kubernetes_client_configuration.client_certificate)
  client_key = base64decode(module.talos-bootstrap.kube_config.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.talos-bootstrap.kube_config.kubernetes_client_configuration.ca_certificate)
}
