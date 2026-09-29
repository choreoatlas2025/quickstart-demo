# ChoreoAtlas CLI Quickstart Demo Makefile
# One-command automation for 10-minute demo experience

.PHONY: demo offline-demo live-demo ci-demo setup clean help convert-trace

# Default target - complete offline demo
demo: offline-demo

# Quick offline demo using pre-recorded traces (2 minutes)
offline-demo: setup
	@echo "🚀 Starting ChoreoAtlas CLI Offline Demo..."
	@echo "📁 Using pre-recorded traces from Sock Shop microservices"
	@./scripts/generate-contracts.sh
	@./scripts/validate-flow.sh
	@echo "✅ Demo complete! Check reports/ (e.g. successful-order-report.html, failed-payment-report.html)"
	@echo "💡 Try: make live-demo for full experience with running services"

# Complete demo with live services (10 minutes)  
live-demo: setup
	@echo "🚀 Starting ChoreoAtlas CLI Live Demo..."
	@echo "🐳 Starting Sock Shop microservices..."
	@./scripts/start-services.sh
	@echo "⏳ Waiting for services to be ready..."
	@sleep 30
	@echo "🔍 Generating traces and contracts..."
	@./scripts/generate-contracts.sh
	@./scripts/validate-flow.sh
	@echo "🛑 Stopping services..."
	@docker-compose down
	@echo "✅ Demo complete! Check reports/ (e.g. report.html, junit.xml)"

# CI integration demo
ci-demo: setup
	@echo "🔧 CI Integration Demo"
	@echo "📋 This shows how to use ChoreoAtlas in your CI pipeline"
	@./scripts/ci-integration-demo.sh

# Setup directories and check prerequisites  
setup:
	@echo "🔧 Setting up demo environment..."
	@mkdir -p contracts/services contracts/flows reports traces
	@chmod +x scripts/*.sh
	@echo "✅ Environment ready"

# Clean up generated files
clean:
	@echo "🧹 Cleaning up..."
	@rm -rf contracts/services/* contracts/flows/* reports/*
	@docker-compose down --volumes 2>/dev/null || true
	@echo "✅ Cleanup complete"

# Help
help:
	@echo "ChoreoAtlas CLI Quickstart Demo"
	@echo ""
	@echo "Available targets:"
	@echo "  demo         - Run complete offline demo (default, 2 mins)"
	@echo "  offline-demo - Quick demo with pre-recorded traces"  
	@echo "  live-demo    - Full demo with running microservices"
	@echo "  ci-demo      - Show CI integration example"
	@echo "  setup        - Initialize demo environment"
	@echo "  clean        - Clean up generated files"
	@echo "  help         - Show this help"
	@echo "  convert-trace IN=... OUT=... [MAP=demo] - Convert Jaeger/OTLP JSON to CE internal format"
	@echo ""
	@echo "Quick start: make demo"

# Convert Jaeger/OTLP JSON to CE internal format
convert-trace:
	@[ -n "$(IN)" ] || (echo "❌ Please provide IN=path/to/input.json" && exit 1)
	@[ -n "$(OUT)" ] || (echo "❌ Please provide OUT=path/to/output.trace.json" && exit 1)
	@echo "🔄 Converting $(IN) -> $(OUT) ..."
	@chmod +x scripts/convert-trace.py
	@python3 scripts/convert-trace.py $(IN) -o $(OUT) $(if $(MAP),--map $(MAP),)
	@echo "✅ Done. Use with: choreoatlas run validate --flow contracts/flows/order-flow.flowspec.yaml --trace $(OUT)"
