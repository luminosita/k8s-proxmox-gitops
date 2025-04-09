output "kube_config" {
  value     = module.talos-bootstrap.kube_config.kubeconfig_raw
  sensitive = true
}

output "versions" {
  value     = {
    talos_version = var.talos_cluster_config.talos_machine_config_version
    kubernetes_version = var.talos_cluster_config.kubernetes_version
  }
}

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

resource "local_file" "kube_config" {
  content         = module.talos-bootstrap.kube_config.kubeconfig_raw
  filename        = "output/kube-config.yaml"
  file_permission = "0600"
}

#FIXME: XXX
# output "gitops" {
#     value = module.gitops.result
# }

