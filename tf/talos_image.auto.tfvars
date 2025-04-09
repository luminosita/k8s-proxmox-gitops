talos_image = {
  version        = "v1.9.2"
  update_version = "v1.9.2" # renovate: github-releases=siderolabs/talos

  image_filename_prefix = "talos-gitops"
  proxmox_datastore     = "local"

  #  schematic_path = "talos/image/schematic.yaml"
  # Point this to a new schematic file to update the schematic
  # update_schematic_path = "talos/image/schematic.yaml"
}
