#!/bin/bash

export KNATIVE_VERSION="v1.14.1"

# Install CRDs
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-crds.yaml

# Install core Knative Serving
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-core.yaml

# Install Knative Istio Controller
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/knative/net-istio/releases/download/knative-${KNATIVE_VERSION}/net-istio.yaml

# Install sslip.io Job for default DNS
kubectl --kubeconfig $KUBECONFIG apply -f https://github.com/knative/serving/releases/download/knative-${KNATIVE_VERSION}/serving-default-domain.yaml