#!/bin/bash

cd ~/${OCI_CCL_DESTINATION_DIR}
tofu init
tofu apply -auto-approve -var="tenancy_ocid=$OCI_TENANCY" || exit
export PUB_LB_NSG_ID=$(tofu output -raw pub_lb_nsg_id)
export OKE_REGION=$(tofu output -raw region)
export OKE_ID=$(tofu output -raw region)

oci ce cluster create-kubeconfig --cluster-id $OKE_ID --file $HOME/.kube/config --region $OKE_REGION --token-version 2.0.0  --kube-endpoint PUBLIC_ENDPOINT

envsubs "$PUB_LB_NSG_ID" < templates/istio-ingress-values.yaml.tpl > istio-ingress-values.yaml

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio-ingressgateway istio/gateway -f istio-ingress-values.yaml --version 1.20.5 --create-namespace
