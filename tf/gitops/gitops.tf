data "kustomization_build" "flux-system" {
  path = "${path.module}/../../k8s/infra/controllers/flux"
}

# first loop through resources in ids_prio[0]
resource "kustomization_resource" "flux-system-0" {
  for_each = data.kustomization_build.flux-system.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )
}

# # then loop through resources in ids_prio[1]
# # and set an explicit depends_on on kustomization_resource.p0
# # wait 2 minutes for any deployment or daemonset to become ready
resource "kustomization_resource" "flux-system-1" {
  for_each = data.kustomization_build.flux-system.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )
  
  wait = true
  
  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [ kustomization_resource.flux-system-0 ]
}

# # finally, loop through resources in ids_prio[2]
# # and set an explicit depends_on on kustomization_resource.p1
resource "kustomization_resource" "flux-system-2" {
  for_each = data.kustomization_build.flux-system.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_build.flux-system.manifests[each.value])
    : data.kustomization_build.flux-system.manifests[each.value]
  )

  depends_on = [ kustomization_resource.flux-system-1 ]
}
