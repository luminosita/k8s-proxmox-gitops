talos_nodes = {
  "ctrl-gitops-00" = {
    host_node    = "proxmox"
    machine_type = "controlplane"
    network = {
      dhcp = true
      ip           = "192.168.50.120"
      #dns           = ["1.1.1.1", "8.8.8.8"] # Optional Value.
      mac_address   = "BC:24:11:2E:C8:05"
      # gateway     = "192.168.50.1"
      # subnet_mask = "24"
    }
    vm_id         = 900
    cpu           = 4
    ram_dedicated = 4096
#    igpu          = true
    datastore_id  = "vm-disks"
  }
  # "work-gitops-00" = {
  #   host_node     = "proxmox"
  #   machine_type  = "worker"
    # network = {
    #   dhcp = true
  #   ip            = "192.168.50.125"
  #   mac_address   = "BC:24:11:2E:C8:06"
  #    # gateway     = "192.168.50.1"
  #    # subnet_mask = "24"
  # }
  #   vm_id         = 910
  #   cpu           = 4
  #   ram_dedicated = 4096
  #   #igpu          = true
  #   #update        = true
  #   datastore_id  = "vm-disks"
  # }
}
