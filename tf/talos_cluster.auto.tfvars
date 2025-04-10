talos_cluster_config = {
  name = "talos"
  # This should point to the vip as below(if nodes on layer 2) or one of the nodes (if nodes not on layer 2)
  # Note: Nodes are not on layer 2 if there is a router between them (even a mesh router)
  #       Not sure how it works if connected to the same router via ethernet (does it act as a switch then???)
  # Ref: https://www.talos.dev/v1.9/talos-guides/network/vip/#requirements
  # Note This is Kubernetes API endpoint. Different from all mentions of Talos endpoints.
  endpoint = "192.168.50.120"
  #vip      = "192.168.50.99"
  network = {
    gateway     = "192.168.50.1"
    subnet_mask = "24"
  }
  # The version of talos features to use in generated machine configuration. Generally the same as image version.
  # See https://github.com/siderolabs/terraform-provider-talos/blob/main/docs/data-sources/machine_configuration.md
  talos_machine_config_version = "v1.9.2"
  region                       = "proxmox"
  kubernetes_version           = "v1.32.3" # renovate: github-releases=kubernetes/kubernetes
  cilium = {
    bootstrap_manifest_path = "inline-manifests/cilium-install.yaml.tftpl"
    values_file_path        = "config/cilium/values.yaml"
    version                 = "v1.17.2"
  }
  extra_manifests = [
    "https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.2.1/standard-install.yaml",
    "https://raw.githubusercontent.com/kubernetes-sigs/gateway-api/v1.2.1/config/crd/experimental/gateway.networking.k8s.io_tlsroutes.yaml"
  ]
  # kubelet    = <<-EOT
  #   extraArgs:
  #     # Needed for Netbird agent https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/#enabling-unsafe-sysctls
  #     allowed-unsafe-sysctls: net.ipv4.conf.all.src_valid_mark
  # EOT
  # api_server = <<-EOT
  #   extraArgs:
  #     oidc-issuer-url: "https://authelia.stonegarden.dev"
  #     oidc-client-id: "kubectl"
  #     oidc-username-claim: "preferred_username"
  #     oidc-username-prefix: "authelia:"
  #     oidc-groups-claim: "groups"
  #     oidc-groups-prefix: "authelia:"
  # EOT
}
