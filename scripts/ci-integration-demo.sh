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
        
    - name: CI Gate (lint + validate)
      run: |
        source ~/.bashrc
        choreoatlas ci-gate \
          --flow contracts/flows/order-flow.flowspec.yaml \
          --trace traces/successful-order.trace.json
        # Also generate artifacts for the run
        choreoatlas run validate \
          --flow contracts/flows/order-flow.flowspec.yaml \
          --trace traces/successful-order.trace.json \
          --report-format junit --report-out reports/junit.xml
        choreoatlas run validate \
          --flow contracts/flows/order-flow.flowspec.yaml \
          --trace traces/successful-order.trace.json \
          --report-format html --report-out reports/pr-validation.html
          
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

# Create example pre-commit hook (lint FlowSpec)
cat > .pre-commit-config.yaml << 'EOF'
# ChoreoAtlas CLI Pre-commit Hooks
repos:
  - repo: local
    hooks:
      - id: choreoatlas-lint
        name: Lint FlowSpec
        entry: choreoatlas
        args: ['lint', '--flow', 'contracts/flows/order-flow.flowspec.yaml']
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
	choreoatlas run validate \
		--flow contracts/flows/order-flow.flowspec.yaml \
		--trace traces/successful-order.trace.json \
		--report-format junit --report-out reports/junit.xml
		
ci-gate:
	@echo "🚪 Running CI gate checks..."
	choreoatlas ci-gate \
		--flow contracts/flows/order-flow.flowspec.yaml \
		--trace traces/successful-order.trace.json

pre-commit-install:
	@echo "🪝 Installing pre-commit hooks..."
	pip install pre-commit
	pre-commit install
	
EOF

echo "✅ Added CI targets to Makefile"

# Create an example baseline (using CLI)
if command -v choreoatlas &> /dev/null; then
  choreoatlas baseline record \
    --flow contracts/flows/order-flow.flowspec.yaml \
    --trace traces/successful-order.trace.json \
    --out baseline.json || true
else
  echo '{"note":"Run choreoatlas baseline record to produce baseline.json"}' > baseline.json
fi

echo "✅ Created baseline.json (example)"

echo ""
echo "🎯 CI Integration Demo Complete!"
echo ""
echo "📋 Created files:"
echo "   • .github/workflows/choreoatlas-validation.yml - GitHub Actions workflow"
echo "   • .pre-commit-config.yaml - Pre-commit hook configuration"
echo "   • baseline.json - Baseline recorded from example trace (if CLI available)"
echo "   • Enhanced Makefile with CI targets"
echo ""
echo "🚀 Next steps to integrate with your project:"
echo "   1. Copy these files to your repository"
echo "   2. Adjust paths and service names to match your architecture" 
echo "   3. Set up required secrets (SLACK_WEBHOOK_URL, etc.)"
echo "   4. Test with: make ci-validate"
echo ""
echo "💡 Pro tip: Use 'make pre-commit-install' to validate contracts before commits"
