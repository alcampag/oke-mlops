#!/bin/bash

export KSERVE_VERSION="v0.13.0"

# Install KServe
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve.yaml

# Install KServe Built-in ClusterServingRuntimes
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/kserve/kserve/releases/download/${KSERVE_VERSION}/kserve-cluster-resources.yaml