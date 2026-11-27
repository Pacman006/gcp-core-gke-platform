#!/usr/bin/env bash
set -euo pipefail

ENV="${ENVIRONMENT:-local}"
echo "Applying Argo CD Application for environment '${ENV}' from ${REPO_URL}..."

cat << YAML | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: platform-api
  namespace: argocd
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: main
    path: k8s/overlays/${ENV}
  destination:
    server: https://kubernetes.default.svc
    namespace: platform-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
YAML
