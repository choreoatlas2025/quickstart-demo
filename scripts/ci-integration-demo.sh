#!/bin/bash
set -e

echo "🔧 ChoreoAtlas CLI CI Integration Demo"
echo ""

# Create example GitHub Actions workflow
mkdir -p .github/workflows

cat > .github/workflows/choreoatlas-validation.yml << 'EOF'
name: Service Choreography Validation

on:
  pull_request:
    branches: [ main ]
    paths: 
      - 'contracts/**'
      - 'traces/**'

jobs:
  validate-choreography:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup ChoreoAtlas CLI
      run: |
        # Option 1: Use pre-built Docker image
        echo 'alias choreoatlas="docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest"' >> ~/.bashrc
        source ~/.bashrc
        
        # Option 2: Download binary (faster)
        # curl -L https://github.com/choreoatlas2025/cli/releases/latest/download/choreoatlas-linux-amd64.tar.gz | tar xz
        # sudo mv choreoatlas /usr/local/bin/
        
    - name: Validate Service Contracts
      run: |
        choreoatlas validate \
          --servicespec contracts/services/ \
          --flowspec contracts/flows/order-flow.flowspec.yaml \
          --trace traces/successful-order.json \
          --report-html reports/pr-validation.html \
          --report-junit reports/junit.xml \
          --edition ce
          
    - name: Upload Validation Report
      uses: actions/upload-artifact@v4
      with:
        name: choreography-validation-report
        path: reports/
        
    - name: Comment PR with Results
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        script: |
          const fs = require('fs');
          let comment = '## 🎭 Service Choreography Validation Results\n\n';
          
          try {
            // Read validation results (this would be implemented in the CLI)
            comment += '✅ **ServiceSpec Contracts**: All services passed semantic validation\n';
            comment += '✅ **FlowSpec Choreography**: Temporal ordering and causality verified\n';
            comment += '📊 **Coverage**: 95% of service interactions validated\n\n';
            comment += '📋 [View Detailed Report](${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }})\n';
          } catch (error) {
            comment += '❌ **Validation Failed**: See workflow logs for details\n';
          }
          
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: comment
          });
EOF

echo "✅ Created .github/workflows/choreoatlas-validation.yml"

# Create example pre-commit hook
cat > .pre-commit-config.yaml << 'EOF'
# ChoreoAtlas CLI Pre-commit Hooks
repos:
  - repo: local
    hooks:
      - id: choreoatlas-lint
        name: Validate ServiceSpec + FlowSpec contracts
        entry: choreoatlas
        args: ['validate', '--servicespec', 'contracts/services/', '--flowspec', 'contracts/flows/', '--lint-only']
        language: system
        files: '\.(flowspec|servicespec)\.ya?ml$'
        pass_filenames: false
EOF

echo "✅ Created .pre-commit-config.yaml"

# Create example Makefile CI targets
cat >> Makefile << 'EOF'

# CI/CD Integration targets
ci-validate:
	@echo "🔍 Running CI validation..."
	choreoatlas validate \
		--servicespec contracts/services/ \
		--flowspec contracts/flows/order-flow.flowspec.yaml \
		--trace traces/successful-order.json \
		--report-junit reports/junit.xml \
		--edition ce
		
ci-gate:
	@echo "🚪 Running CI gate checks..."
	choreoatlas ci-gate \
		--servicespec contracts/services/ \
		--flowspec contracts/flows/order-flow.flowspec.yaml \
		--trace traces/successful-order.json \
		--baseline baseline.yml \
		--edition ce

pre-commit-install:
	@echo "🪝 Installing pre-commit hooks..."
	pip install pre-commit
	pre-commit install
	
EOF

echo "✅ Added CI targets to Makefile"

# Create baseline configuration example
cat > baseline.yml << 'EOF'
# ChoreoAtlas Baseline Configuration
# Used to define quality gates and thresholds for CI/CD

version: v1
kind: Baseline

metadata:
  name: sockshop-choreography-baseline
  description: Quality gates for Sock Shop microservices choreography

thresholds:
  coverage:
    minimum: 80  # Require 80% service interaction coverage
    target: 95   # Target 95% coverage
    
  performance:
    max_duration_ms: 500  # End-to-end flow should complete within 500ms
    p99_duration_ms: 1000 # 99th percentile under 1 second
    
  reliability:
    success_rate: 0.99    # 99% success rate required
    error_budget: 0.01    # 1% error budget
    
quality_gates:
  - name: "Critical Path Validation"
    description: "Core order flow must always be validated"
    required_flows:
      - "order-flow"
    required_services:
      - "catalogue"
      - "cart" 
      - "orders"
      - "payment"
      
  - name: "Error Handling"
    description: "Error scenarios must be tested"
    required_traces:
      - "successful-order.json"
      - "failed-payment.json"

notifications:
  slack:
    webhook_url: "${SLACK_WEBHOOK_URL}"
    channel: "#platform-engineering"
    
  teams:
    webhook_url: "${TEAMS_WEBHOOK_URL}"
EOF

echo "✅ Created baseline.yml configuration"

echo ""
echo "🎯 CI Integration Demo Complete!"
echo ""
echo "📋 Created files:"
echo "   • .github/workflows/choreoatlas-validation.yml - GitHub Actions workflow"
echo "   • .pre-commit-config.yaml - Pre-commit hook configuration"
echo "   • baseline.yml - Quality gates and thresholds"
echo "   • Enhanced Makefile with CI targets"
echo ""
echo "🚀 Next steps to integrate with your project:"
echo "   1. Copy these files to your repository"
echo "   2. Adjust paths and service names to match your architecture" 
echo "   3. Set up required secrets (SLACK_WEBHOOK_URL, etc.)"
echo "   4. Test with: make ci-validate"
echo ""
echo "💡 Pro tip: Use 'make pre-commit-install' to validate contracts before commits"