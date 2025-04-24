variable "proxmox" {
  description = "Proxmox server configuration"
  type = object({
    name         = string
    cluster_name = string
    endpoint     = string
    insecure     = bool

    ssh_username         = string
    ssh_private_key_file = string

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
    factory_url           = optional(string)
    schematic             = optional(string)
    version               = string
    update_schematic      = optional(string)
    update_version        = optional(string)
    arch                  = optional(string)
    platform              = optional(string)
    image_filename_prefix = string
    datastore_id          = string
  })
}

variable "talos_cluster_config" {
  description = "Cluster configuration"
  type = object({
    name                         = string
    endpoint                     = string
    endpoint_port                = optional(string)
    vip                          = optional(string)
    talos_machine_config_version = string
    kubernetes_version           = string
    region                       = string
    extra_manifests              = optional(list(string))
    kubelet                      = optional(string)
    api_server                   = optional(string)
    cilium = object({
      version = string

      bootstrap_manifest_path = optional(string)
      values_file_path        = string
    })
  })
}

variable "talos_nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node    = string
    node_group   = optional(string)
    machine_type = string
    datastore_id = string
    network = object({
      dhcp        = bool
      ip          = optional(string)
      dns         = optional(list(string))
      mac_address = string
      gateway     = optional(string)
      subnet_mask = optional(string)
      device      = optional(string)
      vlan_id     = optional(number)
    })
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    update        = optional(bool, false)
    igpu          = optional(bool, false)
    })
  )
}

variable "sealed_secrets_config" {
  description = "Sealed-secrets configuration"
  type = object({
    certificate_path     = string
    certificate_key_path = string
  })
}
