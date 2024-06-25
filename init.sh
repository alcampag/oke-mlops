#!/bin/bash

cd ~/${OCI_CCL_DESTINATION_DIR}
tofu init || exit
tofu apply -auto-approve -var="tenancy_ocid=$OCI_TENANCY" || exit
export PUB_LB_NSG_ID=$(tofu output -raw pub_lb_nsg_id)
export OKE_REGION=$(tofu output -raw region)
export OKE_ID=$(tofu output -raw oke_cluster_id)

VALUES="
{ service:
  { annotations:
    {
      'oci.oraclecloud.com/load-balancer-type':'lb',
      'service.beta.kubernetes.io/oci-load-balancer-shape':'flexible',
      'service.beta.kubernetes.io/oci-load-balancer-shape-flex-min':'10',
      'service.beta.kubernetes.io/oci-load-balancer-shape-flex-max':'10',
      'oci.oraclecloud.com/oci-network-security-groups': $PUB_LB_NSG_ID,
      'oci.oraclecloud.com/security-rule-management-mode':'None'
    }
    }
    }
"

oci ce cluster create-kubeconfig --cluster-id $OKE_ID --file $HOME/.kube/config --region $OKE_REGION --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT

helm repo add istio https://istio-release.storage.googleapis.com/charts

echo "Waiting for at least one node to be ready"
until kubectl get nodes | grep -i "Ready"; do sleep 1 ;  done

echo "Installing Istio ingress gateway"
echo $VALUES | helm install istio-ingressgateway istio/gateway -f istio-ingress-values.yaml --version 1.20.5 -n istio-system || exit

echo "Installing Knative"
export KNATIVE_VERSION="v1.14.1"

# Install CRDs
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-crds.yaml

# Install core Knative Serving
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-core.yaml

# Install Knative Istio Controller
kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${KNATIVE_VERSION}/net-istio.yaml

# Install sslip.io Job for default DNS
kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-default-domain.yaml

echo "Installing KServe"
export KSERVE_VERSION="v0.13.0"

# Install KServe
kubectl apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml

# Install KServe Built-in ClusterServingRuntimes
kubectl apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-cluster-resources.yaml