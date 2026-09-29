#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

image="${CHOREOATLAS_IMAGE:-choreoatlas/cli:0.2.0-ce.beta.1}"
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required for the CE quickstart." >&2
  exit 1
fi

mkdir -p contracts/flows contracts/services.discovered
rm -f contracts/flows/order-flow.discovered.flowspec.yaml \
  reports/successful-order-report.html reports/failed-payment-report.html
echo "Discovering contracts from the sample trace with ${image}..."
docker run --rm --user "$(id -u):$(id -g)" -v "$PWD:/workspace" -w /workspace "$image" discover \
  --trace traces/successful-order.trace.json \
  --out contracts/flows/order-flow.discovered.flowspec.yaml \
  --out-services contracts/services.discovered

test -s contracts/flows/order-flow.discovered.flowspec.yaml
echo "Discovery complete: contracts/flows/order-flow.discovered.flowspec.yaml"
