resource "helm_release" "istio_ingressgateway" {
  chart = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  name  = "istio-gateway"
  create_namespace = true
  atomic = true
  values = [templatefile("istio-ingress-values.yaml.tpl", {
    PUB_NSG_ID = var.lb_nsg_id
  })]
}

#resource "local_file" "kubeconfig" {
#  filename = "oke-kubeconfig"
#  content = data.oci_containerengine_cluster_kube_config.kube_config.content
#}