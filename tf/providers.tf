terraform {
  required_version = ">= 1.9.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.63.0"
    }    
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.9.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.6.1"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox.endpoint
  insecure = var.proxmox.insecure

  api_token = local.api_token
  
  ssh {
    agent               = false
    username            = var.proxmox.ssh_username
    private_key         = file(var.proxmox.ssh_private_key_file)
  }
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/output/kube-config.yaml"
  }
}

provider "kustomization" {
  kubeconfig_raw = module.talos-bootstrap.kube_config.kubeconfig_raw
}