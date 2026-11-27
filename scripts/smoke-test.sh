#!/usr/bin/env bash
set -euo pipefail

URL="${1:-http://localhost:8080/health}"
echo "Running smoke test against ${URL}..."

RESPONSE=$(curl -fsS "${URL}")
echo "Response: ${RESPONSE}"

if echo "${RESPONSE}" | grep -q '"status":"healthy"'; then
  echo "PASS: platform-api is healthy."
else
  echo "FAIL: Unexpected response from ${URL}"
  exit 1
fi
