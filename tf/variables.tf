variable "proxmox" {
  description = "Proxmox server configuration"
  type = object({
    endpoint = string
    insecure = bool

    ssh_username            = string
    ssh_private_key_file    = string

    iso_datastore = string
  })
}

#Value should be stored in a secure location (i.e HCP Vault) as "root@pam!<token_name>=<token_secret>"
variable "proxmox_api_token" {
  description = "API token for Proxmox"
  type        = string
  sensitive   = true
}

variable "talos_image" {
  description = "Talos image configuration"
  type = object({
    factory_url       = optional(string, "https://factory.talos.dev")
    schematic         = optional(string, "schematic.yaml")
    version           = string
    update_schematic  = optional(string)
    update_version    = optional(string)
    arch              = optional(string, "amd64")
    platform          = optional(string, "nocloud")
    name_prefix       = string
    proxmox_datastore = string
  })
}

variable "talos_cluster_config" {
  description = "Cluster configuration"
  type = object({
    name          = string
    endpoint      = string
    endpoint_port = optional(string, "6443")
    vip           = optional(string)
    network = object({
      gateway     = string
      subnet_mask = optional(string, "24")
    })
    talos_machine_config_version = optional(string)
    kubernetes_version           = string
    proxmox_cluster              = string
    extra_manifests              = optional(list(string))
    kubelet                      = optional(string)
    api_server                   = optional(string)
    cilium = object({
      version = string

      bootstrap_manifest_path = optional(string, "./inline-manifests/cilium-install.tftpl")
      values_file_path        = string
    })
  })
}

variable "talos_nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node     = string
    machine_type  = string
    datastore_id  = string
    ip            = string
    dns           = optional(list(string))
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    update        = optional(bool, false)
    igpu          = optional(bool, false)
    })
  )
  validation {
    // @formatter:off
    condition     = length([for n in var.talos_nodes : n if contains(["controlplane", "worker"], n.machine_type)]) == length(var.talos_nodes)
    error_message = "Node machine_type must be either 'controlplane' or 'worker'."
    // @formatter:on
  }
}
