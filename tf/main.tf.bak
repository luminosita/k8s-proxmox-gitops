locals {
  ci_result = module.cloudinit.result
}

module "cloudinit" {
  source  = "../../terraform-proxmox-cloudinit" #"luminosita/cloudinit/proxmox"
  #version = "0.0.3"

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

  images = { 
    "gitops" = {
      vm_id                       = 2000
      vm_name                     = "gitops"
      vm_node_name                = "proxmox"

      vm_cloud_init               = true

      vm_ci_user                     = "ubuntu"
      vm_ci_ssh_public_key_files     = [
        "~/.ssh/id_rsa.pub",
        "~/.ssh/id_rsa.proxmox.pub"
      ]
      
      vm_ci_write_files           = {
        enabled = true
        content = [{
          path = "/etc/openvpn/server-pass.txt"
          content = local.certs["server-pass.txt"]
        }, {
          path = "/etc/openvpn/passphrase.txt"
          content = local.certs["passphrase.txt"]
        }, {
          path = "/etc/openvpn/client.conf"
          content = templatefile("../templates/client.conf.tpl", {
            ovpn_server = hcloud_server.mikrotik.ipv4_address
            port = 1194
            ca = local.certs["cert_export_MikroTik.crt"]
            client_cert = local.certs["cert_export_chat-server@MikroTik.crt"]
            client_key = local.certs["cert_export_chat-server@MikroTik.key"]
          })
        }]
      }
      
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

resource "null_resource" "kind-cluster" {
  depends_on = [ module.cloudinit ]

  for_each = local.ci_result

  connection {
    type = "ssh"
    user = "ubuntu"
    host = local.ci_result[each.key].ip
    agent = false
    private_key = file("~/.ssh/id_rsa")
  }

  provisioner "file" {
    content = templatefile("../templates/daemon.json.tpl", {
      ip = local.ci_result[each.key].ip
    })

    destination = "/home/ubuntu/daemon.json"
  }

  provisioner "remote-exec" {
    scripts = [ 
      "../scripts/docker.sh",
    ]
  }

  provisioner "local-exec" {
    command = templatefile("../templates/kind.cmd.tpl", {
      ip = local.ci_result[each.key].ip
      name = "gitops"
    })
  }
}
