# ChoreoAtlas CLI Quickstart Demo

**Map. Verify. Steer cross-service choreography from real traces with contracts-as-code.**

This repository provides a complete 10-minute hands-on experience with ChoreoAtlas CLI using a microservices demo based on the Sock Shop architecture.

## 🚀 Quick Start (10 minutes)

### Prerequisites
- Docker and Docker Compose
- Make (GNU Make)
- Latest ChoreoAtlas CLI

### Install ChoreoAtlas CLI

```bash
# Option 1: Docker (no installation needed)
alias choreoatlas='docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest'

# Option 2: Homebrew (macOS/Linux)
brew tap choreoatlas2025/tap
brew install choreoatlas

# Option 3: Download binary
# Visit https://github.com/choreoatlas2025/cli/releases
```

### One-Command Demo

```bash
make demo
```

That's it! This will:
1. 🔍 **Discover** - Generate ServiceSpec + FlowSpec contracts from sample traces
2. ✅ **Validate** - Verify choreography matches execution traces  
3. 📊 **Report** - Generate and open HTML validation report

## 📋 What You'll Learn

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
├── Makefile                   # One-command automation
├── traces/                    # Pre-recorded trace samples
│   ├── successful-order.json  # Happy path trace
│   ├── failed-payment.json    # Error scenario trace
│   └── README.md
├── contracts/                 # Generated contracts
│   ├── services/              # ServiceSpec files (.servicespec.yaml)
│   └── flows/                 # FlowSpec files (.flowspec.yaml)
├── reports/                   # Generated HTML reports
└── scripts/                   # Demo automation scripts
    ├── start-services.sh
    ├── generate-contracts.sh
    └── validate-flow.sh
```

## 🎯 Available Demo Paths

### Path 1: Offline Demo (Fastest - 2 minutes)
Uses pre-recorded traces for immediate contract generation and validation:

```bash
make offline-demo
```

### Path 2: Live Tracing Demo (Complete - 10 minutes)
Starts services, captures real traces, generates contracts:

```bash
make live-demo
```

### Path 3: CI Integration Demo
Shows how to integrate with GitHub Actions:

```bash
make ci-demo
```

## 📖 Step-by-Step Walkthrough

### 1. Discover Contracts from Traces

```bash
# Generate ServiceSpec contracts from traces
choreoatlas discover \
  --trace traces/successful-order.json \
  --out-servicespec contracts/services/ \
  --out-flowspec contracts/flows/order-flow.flowspec.yaml

# Output: ServiceSpec + FlowSpec contracts generated
```

### 2. Validate Choreography

```bash
# Validate actual execution against contracts
choreoatlas validate \
  --servicespec contracts/services/ \
  --flowspec contracts/flows/order-flow.flowspec.yaml \
  --trace traces/successful-order.json \
  --report-html reports/validation-report.html

# Output: Validation results with detailed HTML report
```

### 3. View Results

Open `reports/validation-report.html` to see:
- ✅ Service-level contract compliance
- ✅ Choreography temporal ordering
- ✅ Causal relationship validation
- 📊 Coverage metrics and thresholds

## 🔧 Advanced Usage

### Custom Scenarios

Test different failure modes:

```bash
# Test payment failure scenario
choreoatlas validate \
  --flowspec contracts/flows/order-flow.flowspec.yaml \
  --trace traces/failed-payment.json \
  --report-html reports/failure-analysis.html
```

### CI Integration

Add to your `.github/workflows/validate.yml`:

```yaml
- name: Validate Service Choreography
  uses: choreoatlas2025/action@v1
  with:
    servicespec: contracts/services/
    flowspec: contracts/flows/order-flow.flowspec.yaml
    trace: traces/integration-test.json
```

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