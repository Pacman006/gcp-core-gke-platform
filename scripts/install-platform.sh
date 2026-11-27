#!/usr/bin/env bash
set -euo pipefail

CURRENT_CTX=$(kubectl config current-context)
if [[ "${CURRENT_CTX}" != "${EXPECTED_CONTEXT}" ]]; then
  echo "ERROR: Expected context '${EXPECTED_CONTEXT}', but active context is '${CURRENT_CTX}'"
  exit 1
fi

echo "Installing Argo CD (${ARGO_CHART_VERSION})..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version "${ARGO_CHART_VERSION}" \
  --set server.service.type=ClusterIP \
  --wait --timeout 5m

echo "Installing kube-prometheus-stack (${MONITOR_CHART_VERSION})..."
helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --version "${MONITOR_CHART_VERSION}" \
  --set grafana.service.type=ClusterIP \
  --set alertmanager.enabled=false \
  --wait --timeout 5m

echo "Platform add-ons installed successfully."
