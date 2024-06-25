#!/bin/bash

cd ~/${OCI_CCL_DESTINATION_DIR}
tofu apply -auto-approve -var="tenancy_ocid=$OCI_TENANCY" || exit
export PUB_LB_NSG_ID=$(tofu output -raw pub_lb_nsg_id)

envsubs "$PUB_LB_NSG_ID" < templates/istio-ingress-values.yaml.tpl > istio-ingress-values.yaml

helm repo add istio https://istio-release.storage.googleapis.com/charts
helm install istio-ingressgateway istio/gateway -f istio-ingress-values.yaml --version 1.20.5 --create-namespace
