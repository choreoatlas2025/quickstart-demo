# ChoreoAtlas CLI Quickstart Demo

Map. Verify. Steer cross‑service choreography with Contract‑as‑Code.

This quickstart gives you a 2–10 minute, developer‑friendly journey using the ChoreoAtlas CLI with a Sock Shop–style microservices example. It is aligned with the current Community Edition (CE) CLI.

中文文档请见 README.zh-CN.md

## 🚀 Quick Start (10 minutes)

### Prerequisites
- Docker and Docker Compose
- Make (GNU Make)
- ChoreoAtlas CLI (or use the Docker image)

### Install ChoreoAtlas CLI

```bash
# Option 1: Docker (no local install needed)
alias choreoatlas='docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest'

# Option 2: Homebrew (macOS/Linux)
brew tap choreoatlas2025/tap
brew install choreoatlas

# Option 3: Download binary
# Visit https://github.com/choreoatlas2025/cli/releases
```

### One‑Command Demo

```bash
make demo
```

That’s it! This will:
1. 🔍 Discover: generate FlowSpec + ServiceSpecs from sample traces
2. ✅ Validate: verify choreography against execution traces
3. 📊 Report: generate an HTML report under `reports/`

## 📋 What You’ll Learn

- **ServiceSpec**: Service-level semantic validation with pre/post conditions
- **FlowSpec**: Choreography-level temporal, causal, and DAG validation
- **Contract-as-Code**: Turn traces into executable governance contracts
- **CI Integration**: Gate deployments with choreography validation

## 🏗️ Demo Architecture

The demo simulates an e-commerce microservices system:

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│   Frontend  │───▶│   Catalog    │───▶│  Database   │
└─────────────┘    └──────────────┘    └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│    Cart     │───▶│    Orders    │───▶│   Payment   │
└─────────────┘    └──────────────┘    └─────────────┘
```

## 📁 Repository Structure

```
.
├── docker-compose.yml          # Sock Shop services (simplified)
├── Makefile                   # One‑command automation
├── traces/                    # Pre-recorded trace samples
│   ├── successful-order.trace.json  # Internal format (CE) – happy path
│   ├── failed-payment.trace.json    # Internal format (CE) – failure scenario
│   ├── successful-order.json        # Jaeger‑style sample (for reference)
│   ├── failed-payment.json          # Jaeger‑style sample (for reference)
│   └── README.md
├── contracts/                 # Contracts (generated + curated)
│   ├── services/              # ServiceSpec files (.servicespec.yaml)
│   └── flows/                 # FlowSpec files (sequential + graph)
│       ├── order-flow.flowspec.yaml         # sequential (legacy)
│       └── order-flow.graph.flowspec.yaml   # graph/DAG (preferred)
├── reports/                   # Generated HTML reports
└── scripts/                   # Demo automation scripts
    ├── start-services.sh
    ├── generate-contracts.sh
    └── validate-flow.sh
```

## 🎯 Available Demo Paths

### Path 1: Offline Demo (Fastest — 2 minutes)
Uses pre-recorded traces for immediate contract generation and validation:

```bash
make offline-demo
```

### Path 2: Live Tracing Demo (Complete — ~10 minutes)
Starts services, captures real traces, generates contracts:

```bash
make live-demo
```

### Path 3: CI Integration Demo
Shows how to integrate with GitHub Actions:

```bash
make ci-demo
```

## 📖 Step‑by‑Step Walkthrough

### 1. Discover Contracts from Traces

```bash
# Generate FlowSpec and ServiceSpecs from a trace (CE format)
choreoatlas discover \
  --trace traces/successful-order.trace.json \
  --out contracts/flows/order-flow.flowspec.yaml \
  --out-services contracts/services

# Output: FlowSpec + ServiceSpec files generated
```

### 2. Validate Choreography

```bash
# Validate actual execution against contracts
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format html --report-out reports/validation-report.html

# Optional: also emit JSON or JUnit
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format json --report-out reports/validation-report.json
```

### 3. View Results

Open `reports/validation-report.html` to see:
- ✅ Service-level contract compliance
- ✅ Choreography temporal ordering
- ✅ Causal relationship validation
- 📊 Coverage metrics and thresholds

Note: The demo does not auto-open a browser. Open HTML files under `reports/` manually (for example, `reports/validation-report.html` or `reports/successful-order-report.html`).

## 🔧 Advanced Usage

### Custom Scenarios

Test different failure modes:

```bash
# Test payment failure scenario
choreoatlas validate \
  --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/failed-payment.trace.json \
  --report-format html --report-out reports/failure-analysis.html
```

### CI Integration

A ready-to-run workflow is included: `.github/workflows/choreoatlas-validation.yml`.
- Runs `ci-gate` (lint + validate).
- Generates `reports/junit.xml` and `reports/report.html`.
- Prefers `order-flow.graph.flowspec.yaml` when present; falls back to the sequential file.

### Trace Conversion (Jaeger/OTLP → CE)

If your traces are Jaeger or OTLP JSON, convert them into the CE internal format with the provided tool:

```bash
# Jaeger -> CE internal
make convert-trace IN=traces/successful-order.json OUT=traces/successful-order.trace.json MAP=demo

# OTLP -> CE internal
make convert-trace IN=traces/otlp-sample.json OUT=traces/otlp-sample.trace.json

# Or directly via Python
python3 scripts/convert-trace.py traces/successful-order.json \
  -o traces/successful-order.trace.json --map demo

# Then validate
choreoatlas validate --flow contracts/flows/order-flow.graph.flowspec.yaml \
  --trace traces/successful-order.trace.json \
  --report-format html --report-out reports/from-converted.html
```

Notes:
- The converter supports two inputs: Jaeger-style JSON (spans[].operationName) and OTLP JSON (resourceSpans[]...).
- Operation names may need mapping to your ServiceSpec operationId. Use `--map demo` for the Sock Shop endpoints, or `--map-file` with your own mapping.
- Real-world traces often lack full response bodies; validations based on `response.body.*` may SKIP/FAIL. Status-code checks still work.

## 🎓 Next Steps

1. **Apply to Your Services**: Use `choreoatlas discover` with your own traces
2. **Set Up CI Gates**: Add choreography validation to your pipeline  
3. **Explore Pro Features**: Advanced baselines, trend analysis, privacy controls
4. **Join Community**: https://github.com/choreoatlas2025/cli/discussions

## 📚 Documentation

- **Full Documentation**: https://choreoatlas.io
- **ServiceSpec Guide**: https://choreoatlas.io/docs/servicespec
- **FlowSpec Guide**: https://choreoatlas.io/docs/flowspec  
- **CI Integration**: https://choreoatlas.io/docs/ci

## 🤝 Support & Community

- **GitHub Issues**: https://github.com/choreoatlas2025/cli/issues
- **Discussions**: https://github.com/choreoatlas2025/cli/discussions
- **Email**: support@choreoatlas.com

---

**ChoreoAtlas CLI** - From traces to executable contracts in minutes, not months.
