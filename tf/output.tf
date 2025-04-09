output "talos-image" {
    value = module.talos-image.result
}

#FIXME: XXXX
# output "kube_config" {
#   value     = module.talos-bootstrap.kube_config.kubeconfig_raw
#   sensitive = true
# }

output "talos_config" {
  value     = module.talos-bootstrap.client_configuration.talos_config
  sensitive = true
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

#FIXME: XXXX
# resource "local_file" "kube_config" {
#   content         = module.talos-bootstrap.kube_config.kubeconfig_raw
#   filename        = "output/kube-config.yaml"
#   file_permission = "0600"
# }

#FIXME: XXXX
# output "gitops" {
#     value = module.gitops.result
# }

