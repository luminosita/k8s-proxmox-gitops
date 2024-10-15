locals {
  ci_result = module.cloudinit.result

  images = { 
    "gitops" = {
      vm_user                     = "ubuntu"
      vm_ssh_public_key_files     = [
        "~/.ssh/id_rsa.pub",
        "~/.ssh/id_rsa.proxmox.pub"
      ]
      
      vm_id                       = 2000
      vm_name                     = "gitops"
      vm_node_name                = "proxmox"

      vm_cloud_init               = true

      vm_ci_reboot_enabled        = true

      vm_ci_run_cmds      = {
        enabled = true
        content = [
          "install -m 0755 -d /etc/apt/keyrings",
          "curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
          "chmod a+r /etc/apt/keyrings/docker.asc",
          "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
          "apt-get update",
          "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
          "usermod -aG docker ubuntu",
          "curl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"",
          "install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl"
        ]
      }
    }
  }
}

module "cloudinit" {
  source  = "luminosita/cloudinit/proxmox"
  version = "0.0.3"

  providers = {
    proxmox = proxmox
  }

  os = { 
    vm_base_url                 = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
    vm_base_image               = "noble-server-cloudimg-amd64.img"
    vm_base_image_checksum      = "fad101d50b06b26590cf30542349f9e9d3041ad7929e3bc3531c81ec27f2c788"    
    vm_base_image_checksum_alg  = "sha256"
    vm_node_name                = "proxmox"
  }

  images = local.images
}

resource "null_resource" "run" {
  depends_on = [ module.cloudinit ]

  for_each = local.ci_result

  connection {
    type = "ssh"
    user = "ubuntu"
    host = local.ci_result[each.key].ip
    agent = false
    private_key = file("~/.ssh/id_rsa")
  }

  ###################### KIND ####################

  provisioner "file" {
    source = "../config/config.yaml"
    destination = "/home/ubuntu/config.yaml"
  }

  provisioner "remote-exec" {
    scripts = [ 
      "../scripts/kind.sh",
    ]
  }

  provisioner "local-exec" {
    command = "source ../scripts/finalize.sh"
    environment = {
      IP = local.ci_result[each.key].ip
      NAME = each.key
    }
  }
}

