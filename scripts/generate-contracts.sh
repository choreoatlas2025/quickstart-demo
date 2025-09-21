#!/bin/bash
set -e

echo "🔍 Generating ServiceSpec + FlowSpec contracts from traces..."

# Determine execution method: native CLI, Docker, or fallback to templates
EXECUTION_METHOD=""
CHOREOATLAS_CMD=""

if command -v choreoatlas &> /dev/null; then
    EXECUTION_METHOD="native"
    CHOREOATLAS_CMD="choreoatlas"
    echo "✅ Found native ChoreoAtlas CLI"
elif command -v docker &> /dev/null; then
    echo "⚠️  Native CLI not found, checking Docker..."
    if docker image inspect choreoatlas/cli:latest &> /dev/null; then
        EXECUTION_METHOD="docker"
        CHOREOATLAS_CMD="docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest"
        echo "✅ Using Docker image: choreoatlas/cli:latest"
    else
        echo "📦 Docker image not found locally, attempting to pull..."
        if docker pull choreoatlas/cli:latest &> /dev/null; then
            EXECUTION_METHOD="docker"
            CHOREOATLAS_CMD="docker run --rm -v $(pwd):/workspace choreoatlas/cli:latest"
            echo "✅ Successfully pulled and will use Docker image"
        else
            echo "❌ Failed to pull Docker image"
            EXECUTION_METHOD="fallback"
        fi
    fi
else
    echo "❌ Neither ChoreoAtlas CLI nor Docker available"
    EXECUTION_METHOD="fallback"
fi

# Ensure directories exist
mkdir -p contracts/services contracts/flows

echo "📊 Discovering contracts from successful order trace (CE format)..."

case $EXECUTION_METHOD in
    "native"|"docker")
        echo "🔍 Attempting contract discovery with $EXECUTION_METHOD method..."
        
        # Check if discover command is available
        if $CHOREOATLAS_CMD --help 2>/dev/null | grep -q "discover"; then
            echo "✅ Discover command found, generating contracts from trace..."
            
            if [ "$EXECUTION_METHOD" = "docker" ]; then
                # For Docker, we need to adjust paths to container paths
                if $CHOREOATLAS_CMD discover \
                    --trace /workspace/traces/successful-order.trace.json \
                    --out /workspace/contracts/flows/order-flow.flowspec.yaml \
                    --out-services /workspace/contracts/services 2>/dev/null; then
                    echo "✅ ServiceSpec contracts generated in contracts/services/"
                    echo "✅ FlowSpec contract generated: contracts/flows/order-flow.flowspec.yaml"
                else
                    echo "⚠️  Discovery command failed, using pre-generated contracts..."
                    cp -r templates/contracts/* contracts/
                fi
            else
                # Native CLI with local paths
                if $CHOREOATLAS_CMD discover \
                    --trace traces/successful-order.trace.json \
                    --out contracts/flows/order-flow.flowspec.yaml \
                    --out-services contracts/services 2>/dev/null; then
                    echo "✅ ServiceSpec contracts generated in contracts/services/"
                    echo "✅ FlowSpec contract generated: contracts/flows/order-flow.flowspec.yaml"
                else
                    echo "⚠️  Discovery command failed, using pre-generated contracts..."
                    cp -r templates/contracts/* contracts/
                fi
            fi
        else
            echo "⚠️  Discover command not available yet, using pre-generated contracts..."
            cp -r templates/contracts/* contracts/
        fi
        ;;
    "fallback")
        echo "📋 Using pre-generated contracts (no CLI available)..."
        cp -r templates/contracts/* contracts/
        ;;
esac

# List generated files
echo ""
echo "📁 Generated contract files:"
find contracts -name "*.yaml" -o -name "*.yml" | sort

echo ""
echo "🎯 Contract discovery complete!"
echo "💡 Next: Run './scripts/validate-flow.sh' to validate choreography"
