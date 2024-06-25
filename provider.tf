terraform {
  required_version = ">=1.6.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "5.46.0"
      configuration_aliases = [oci.home]
    }
    local = {
      source = "hashicorp/local"
      version = "2.5.1"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.14.0"
    }
    null = {
      source = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

provider "oci" {
  region = var.region
}

provider "oci" {
  alias = "home"
  region = one(data.oci_identity_region_subscriptions.home.region_subscriptions[*].region_name)
}

provider "helm" {
  kubernetes {
    host                   = local.kube_host
    cluster_ca_certificate = local.kube_cluster_ca_certificate
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["ce", "cluster", "generate-token", "--cluster-id", module.oke.cluster_id, "--region", var.region]
      command     = "oci"
    }
  }
}