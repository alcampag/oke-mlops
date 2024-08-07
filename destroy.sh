#!/bin/bash


export OKE_COMPARTMENT=$(tofu output -raw compartment_id)
export OKE_REGION=$OCI_REGION

helm uninstall istio-ingressgateway --wait -n istio-system || true
helm uninstall oke-mlflow --wait -n mlflow || true
tofu destroy -var="tenancy_ocid=$OCI_TENANCY" -var="region=$OKE_REGION" -var="compartment_ocid=$OKE_COMPARTMENT"