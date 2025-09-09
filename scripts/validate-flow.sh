#!/bin/bash
set -e

echo "✅ Validating choreography against ServiceSpec + FlowSpec contracts..."

# Check prerequisites
if ! command -v choreoatlas &> /dev/null; then
    echo "❌ ChoreoAtlas CLI not found"
    exit 1
fi

if [ ! -f "contracts/flows/order-flow.flowspec.yaml" ]; then
    echo "❌ FlowSpec contract not found. Run './scripts/generate-contracts.sh' first."
    exit 1
fi

# Ensure reports directory exists
mkdir -p reports

echo "🔍 Validating successful order flow..."
# Validate successful scenario
if choreoatlas validate \
    --servicespec contracts/services/ \
    --flowspec contracts/flows/order-flow.flowspec.yaml \
    --trace traces/successful-order.json \
    --report-html reports/successful-order-report.html \
    --report-json reports/successful-order-report.json \
    --edition ce; then
    echo "✅ Successful order validation: PASSED"
else
    echo "❌ Successful order validation: FAILED (see report for details)"
fi

echo ""
echo "🔍 Validating failed payment scenario..."
# Validate failure scenario
if choreoatlas validate \
    --servicespec contracts/services/ \
    --flowspec contracts/flows/order-flow.flowspec.yaml \
    --trace traces/failed-payment.json \
    --report-html reports/failed-payment-report.html \
    --report-json reports/failed-payment-report.json \
    --edition ce; then
    echo "✅ Failed payment validation: PASSED (error handling validated)"
else
    echo "⚠️  Failed payment validation: Detected choreography violations (expected)"
fi

echo ""
echo "📊 Validation complete! Generated reports:"
find reports -name "*.html" | while read -r report; do
    echo "   🌐 $(basename "$report"): file://$(realpath "$report")"
done

# Try to open the main report
if command -v open &> /dev/null; then
    echo ""
    echo "🚀 Opening validation report..."
    open reports/successful-order-report.html
elif command -v xdg-open &> /dev/null; then
    echo ""
    echo "🚀 Opening validation report..."
    xdg-open reports/successful-order-report.html
else
    echo ""
    echo "💡 Open reports/successful-order-report.html in your browser to view results"
fi

echo ""
echo "🎯 Demo complete! Key takeaways:"
echo "   • ServiceSpec contracts validate individual service behavior"
echo "   • FlowSpec contracts validate end-to-end choreography"
echo "   • Error scenarios help verify circuit breaker patterns"
echo "   • HTML reports provide detailed analysis and coverage metrics"