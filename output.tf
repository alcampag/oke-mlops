output "pub_lb_nsg_id" {
  value = module.oke.pub_lb_nsg_id
}

output "oke_cluster_id" {
  value = module.oke.cluster_id
}

output "compartment_id" {
  value = var.compartment_ocid
}