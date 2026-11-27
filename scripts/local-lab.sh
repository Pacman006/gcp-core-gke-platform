#!/usr/bin/env bash
set -euo pipefail

echo "Creating namespace platform-app..."
kubectl create namespace platform-app --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying local overlay..."
kubectl apply -k k8s/overlays/local

echo "Waiting for platform-api rollout..."
kubectl -n platform-app rollout status deployment/platform-api --timeout=90s
