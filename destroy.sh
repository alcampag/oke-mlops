#!/bin/bash


export OKE_COMPARTMENT=$(tofu output -raw compartment_id)
export OKE_REGION=$(tofu output -raw region)

helm uninstall istio-ingressgateway --wait --ignore-not-found -n istio-system
helm uninstall oke-mlflow --wait --ignore-not-found -n mlflow
tofu destroy -var="tenancy_ocid=$OCI_TENANCY" -var="region=$OKE_REGION" -var="compartment_ocid=$OKE_COMPARTMENT"