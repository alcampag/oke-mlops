#!/bin/bash

cd ~/"${OCI_CCL_DESTINATION_DIR}" || exit
tofu init || exit
tofu apply -var="tenancy_ocid=$OCI_TENANCY" -var="region=$OCI_REGION" || exit
export PUB_LB_NSG_ID=$(tofu output -raw pub_lb_nsg_id)
export OKE_ID=$(tofu output -raw oke_cluster_id)

rm -f istio-ingress-values.yaml
cat <<EOF | tee istio-ingress-values.yaml
service:
  annotations:
    {
      "oci.oraclecloud.com/load-balancer-type":"lb",
      "service.beta.kubernetes.io/oci-load-balancer-shape":"flexible",
      "service.beta.kubernetes.io/oci-load-balancer-shape-flex-min":"10",
      "service.beta.kubernetes.io/oci-load-balancer-shape-flex-max":"10",
      "oci.oraclecloud.com/oci-network-security-groups":"${PUB_LB_NSG_ID}",
      "oci.oraclecloud.com/security-rule-management-mode":"None"
    }
EOF

oci ce cluster create-kubeconfig --cluster-id $OKE_ID --file $HOME/.kube/config --region $OCI_REGION --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT

helm repo add istio https://istio-release.storage.googleapis.com/charts

echo "Waiting for all nodes to be ready"
kubectl wait --for=condition=Ready nodes --all --timeout=300s

export ISTIO_VERSION="1.20.5"
echo "Installing Istio"

helm upgrade --install istio-base istio/base -n istio-system --version $ISTIO_VERSION --create-namespace --wait || exit
helm upgrade --install istiod istio/istiod -n istio-system --version $ISTIO_VERSION --wait || exit

echo "Installing Istio ingress gateway"
helm upgrade --install istio-ingressgateway istio/gateway -f istio-ingress-values.yaml --version $ISTIO_VERSION -n istio-system --wait || exit

echo "Installing Knative"
export KNATIVE_VERSION="v1.14.1"

# Install CRDs
while ! kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-crds.yaml; do echo "Retrying installing Knative CRDs"; sleep 10; done

# Install core Knative Serving
while ! kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-core.yaml; do echo "Retrying installing Knative Serving"; sleep 10; done

# Install Knative Istio Controller
while ! kubectl apply -f https://github.com/knative/net-istio/releases/download/knative-${KNATIVE_VERSION}/net-istio.yaml; do echo "Retrying installing Knative Istio Controller"; sleep 10; done

# Install sslip.io Job for default DNS
while ! kubectl apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-default-domain.yaml; do echo "Retrying installing Knative Domain Job"; sleep 10; done

echo "Installing KServe"
export KSERVE_VERSION="v0.13.0"

# Install KServe
while ! kubectl apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml; do echo "Retrying installing KServe"; sleep 10; done

# Install KServe Built-in ClusterServingRuntimes
while ! kubectl apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-cluster-resources.yaml; do echo "Retrying installing KServe Cluster Resources"; sleep 10; done