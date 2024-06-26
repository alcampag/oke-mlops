module "oke" {
  source  = "oracle-terraform-modules/oke/oci"
  version = "5.1.7"
  compartment_id = var.compartment_ocid
  # IAM - Policies
  create_iam_autoscaler_policy = "never"
  create_iam_kms_policy = "never"
  create_iam_operator_policy = "never"
  create_iam_worker_policy = "never"
  # Network module - VCN
  subnets = {
    bastion = { create = "always",
      newbits = 13 }
    operator = { create = "never" }
    pub_lb = { newbits = 11 }
    int_lb = { create = "never" }
    cp = { newbits = 13 }
    workers = { newbits = 2 }
    pods = {newbits = 3 }
  }
  nsgs = {
    bastion = {create = "always"}
    operator = { create = "never"}
    pub_lb = {create = "always"}
    int_lb = {create = "never"}
    cp = {create = "always"}
    workers = {create = "always"}
    pods = {create = "always"}
  }
  network_compartment_id = var.compartment_ocid
  assign_public_ip_to_control_plane = true
  assign_dns = true
  create_vcn = true
  vcn_cidrs = ["10.0.0.0/16"]
  vcn_dns_label = "oke"
  vcn_name = "oke-alcampag-mlops-vcn"
  lockdown_default_seclist = true
  allow_rules_public_lb ={
    "Allow TCP ingress to public load balancers for HTTPS traffic from anywhere" : { protocol = 6, port = 443, source="0.0.0.0/0", source_type="CIDR_BLOCK"},
    "Allow TCP ingress to public load balancers for HTTP traffic from anywhere" : { protocol = 6, port = 80, source="0.0.0.0/0", source_type="CIDR_BLOCK"}
  }
  # Network module - security
  allow_node_port_access = true
  allow_pod_internet_access = true
  allow_worker_internet_access = true
  allow_worker_ssh_access = true
  control_plane_allowed_cidrs = ["0.0.0.0/0"]
  control_plane_is_public = true
  enable_waf = false
  load_balancers = "public"
  preferred_load_balancer = "public"
  worker_is_public = false
  # Network module - routing
  ig_route_table_id = null # Only to select with existing VCN, may be optional
  nat_route_table_id = null # Only to select with existing VCN, may be optional
  # Cluster module
  create_cluster = true
  cluster_kms_key_id = null
  cluster_name = "oke-alcampag-mlops"
  cluster_type = "enhanced"
  cni_type = "npn"  #flannel
  image_signing_keys = []
  kubernetes_version = "v1.29.1"
  pods_cidr          = "10.244.0.0/16"
  services_cidr      = "10.96.0.0/16"
  use_signed_images  = false
  use_defined_tags = false
  # Workers
  worker_pool_mode = "node-pool"
  worker_pool_size = 2
  worker_image_type = "custom"
  worker_image_id = local.oke_x86_image_id
  freeform_tags = {
    workers = {
      "cluster" = "oke-alcampag"
    }
  }
  worker_pools = {
    np1 = {
      shape = "VM.Standard.E4.Flex",
      ocpus = 2,
      memory = 16,
      boot_volume_size = 50,
      node_cycling_enabled = false,
      create = true

    }
  }

  # Bastion
  create_bastion = false

  # Operator
  create_operator = false

  providers = {
    oci.home = oci.home
  }
}

resource "oci_containerengine_addon" "oke_cert_manager" {
  addon_name                       = "CertManager"
  cluster_id                       = module.oke.cluster_id
  remove_addon_resources_on_delete = false
  depends_on = [module.oke]
}

resource "oci_containerengine_addon" "oke_metrics_server" {
  addon_name                       = "KubernetesMetricsServer"
  cluster_id                       = module.oke.cluster_id
  remove_addon_resources_on_delete = false
  depends_on = [module.oke, oci_containerengine_addon.oke_cert_manager]
}

/*resource "oci_containerengine_addon" "oke_istio" {
  addon_name                       = "Istio"
  cluster_id                       = module.oke.cluster_id
  remove_addon_resources_on_delete = true
  configurations {
    key = "enableIngressGateway"
    value = "false"
  }
  configurations {
    key = "customizeConfigMap"
    value = "true"
  }
  depends_on = [module.oke, oci_containerengine_addon.oke_cert_manager]
}*/
#
# module "oke-install" {
#   source = "./modules/oke-install"
#   lb_nsg_id = module.oke.pub_lb_nsg_id
#   pool_ips = module.oke.worker_pool_ips
# }
