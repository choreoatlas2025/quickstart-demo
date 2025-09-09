#!/bin/bash
set -e

echo "🔍 Generating ServiceSpec + FlowSpec contracts from traces..."

# Check if choreoatlas CLI is available
if ! command -v choreoatlas &> /dev/null; then
    echo "❌ ChoreoAtlas CLI not found. Please install:"
    echo "   brew tap choreoatlas2025/tap && brew install choreoatlas"
    echo "   OR use Docker: alias choreoatlas='docker run --rm -v \$(pwd):/workspace choreoatlas/cli:latest'"
    exit 1
fi

# Ensure directories exist
mkdir -p contracts/services contracts/flows

echo "📊 Discovering contracts from successful order trace..."
# Generate contracts from successful order trace
if choreoatlas discover \
    --trace traces/successful-order.json \
    --out-servicespec contracts/services/ \
    --out-flowspec contracts/flows/order-flow.flowspec.yaml \
    --format yaml; then
    echo "✅ ServiceSpec contracts generated in contracts/services/"
    echo "✅ FlowSpec contract generated: contracts/flows/order-flow.flowspec.yaml"
else
    echo "⚠️  Discovery failed, using pre-generated contracts..."
    # Fallback: copy pre-generated contracts if discovery fails
    cp -r templates/contracts/* contracts/ 2>/dev/null || true
fi

# List generated files
echo ""
echo "📁 Generated contract files:"
find contracts -name "*.yaml" -o -name "*.yml" | sort

echo ""
echo "🎯 Contract discovery complete!"
echo "💡 Next: Run './scripts/validate-flow.sh' to validate choreography"