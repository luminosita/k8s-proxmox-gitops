output "talos-image" {
    value = module.talos-image.result
}

output "kube_config" {
  value     = module.talos-bootstrap.kube_config.kubeconfig_raw
  sensitive = true
}

output "talos_config" {
  value     = module.talos-bootstrap.client_configuration.talos_config
  sensitive = true
}

output "image_schematic" {
  // "dcac6b92c17d1d8947a0cee5e0e6b6904089aa878c70d66196bb1138dbd05d1a"
  value = module.talos-image.schematic_id
}

resource "local_file" "machine_configs" {
  for_each        = module.talos-bootstrap.machine_config
  content         = each.value.machine_configuration
  filename        = "output/talos-machine-config-${each.key}.yaml"
  file_permission = "0600"
}

resource "local_file" "talos_config" {
  content         = module.talos-bootstrap.client_configuration.talos_config
  filename        = "output/talos-config.yaml"
  file_permission = "0600"
}

resource "local_file" "kube_config" {
  content         = module.talos-bootstrap.kube_config.kubeconfig_raw
  filename        = "output/kube-config.yaml"
  file_permission = "0600"
}
