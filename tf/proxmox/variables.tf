variable "image" {
  description = "Talos image configuration"
  type = object({
    file_name = string
    file_name_update = string
    url = string
    url_update = string
    proxmox_datastore = optional(string, "local")
  })
}

variable "nodes" {
  description = "Configuration for cluster nodes"
  type = map(object({
    host_node     = string
    machine_type  = string
    datastore_id = optional(string, "local-zfs")
    ip            = string
    mac_address   = string
    vm_id         = number
    cpu           = number
    ram_dedicated = number
    update = optional(bool, false)
    igpu = optional(bool, false)
  }))
}

variable "gateway" {
  type = string
}