talos_nodes = {
  "ctrl-gitops-00" = {
    host_node    = "proxmox"
    machine_type = "controlplane"
    network = {
      dhcp        = false
      ip          = "192.168.50.60"
      mac_address = "bc:24:11:2e:c8:05"
      gateway     = "192.168.50.1"
      subnet_mask = "24"
    }
    vm_id         = 900
    cpu           = 4
    ram_dedicated = 4096
    #    igpu          = true
    datastore_id = "vm-disks"
  }
  "work-gitops-00" = {
    host_node    = "proxmox"
    machine_type = "worker"
    network = {
      dhcp        = false
      ip          = "192.168.50.65"
      mac_address = "bc:24:11:2e:c8:06"
      gateway     = "192.168.50.1"
      subnet_mask = "24"
    }
    vm_id         = 910
    cpu           = 4
    ram_dedicated = 4096
    #igpu          = true
    #update        = true
    datastore_id = "vm-disks"
  }
}
