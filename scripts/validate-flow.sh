#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

image="${CHOREOATLAS_IMAGE:-choreoatlas/cli:0.2.0-ce.beta.1}"
flow="contracts/flows/order-flow.graph.flowspec.yaml"
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required for the CE quickstart." >&2
  exit 1
fi
test -s "$flow"
test -s traces/successful-order.trace.json
test -s traces/failed-payment.trace.json

run_cli() {
  docker run --rm -v "$PWD:/workspace" -w /workspace "$image" "$@"
}

mkdir -p reports
rm -f reports/successful-order-report.html reports/failed-payment-report.html

echo "Validating the successful order trace..."
run_cli validate --flow "$flow" \
  --trace traces/successful-order.trace.json \
  --report-format html --report-out reports/successful-order-report.html
test -s reports/successful-order-report.html

echo "Validating the failed payment trace (a validation failure is expected)..."
set +e
run_cli validate --flow "$flow" \
  --trace traces/failed-payment.trace.json \
  --report-format html --report-out reports/failed-payment-report.html
status=$?
set -e
if [[ "$status" -ne 3 && "$status" -ne 4 ]]; then
  echo "Expected validation exit code 3 or gate exit code 4; received ${status}." >&2
  exit 1
fi
test -s reports/failed-payment-report.html

echo "Real CLI reports: reports/successful-order-report.html and reports/failed-payment-report.html"
