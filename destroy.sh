#!/bin/bash


export OKE_COMPARTMENT=$(tofu output -raw compartment_id)
export OKE_REGION=$(tofu output -raw region)

kubectl delete service istio-ingressgateway -n istio-system
tofu destroy -var="tenancy_ocid=$OCI_TENANCY" -var="region=$OKE_REGION" -var="compartment_ocid=$OKE_COMPARTMENT"