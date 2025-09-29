# Sample Traces

This directory contains pre-recorded trace data for the ChoreoAtlas CLI quickstart demo.

## Trace Files

### successful-order.trace.json
Internal CE format — Happy path scenario
- Flow: Catalogue → Cart → Orders → Payment → Shipping
- Services: catalogue, cart, orders, payment, shipping
- Result: ✅ All services respond successfully
- Use Case: Works out-of-the-box with CE CLI

### failed-payment.trace.json
Internal CE format — Error scenario
- Flow: Catalogue → Cart → Orders → Payment (declined)
- Services: catalogue, cart, orders, payment
- Result: ❌ Payment service returns 402 (insufficient funds)
- Use Case: Validate error handling and gating

### successful-order.json, failed-payment.json
Jaeger/OTLP-style reference samples (for conversion or comparison).

## Trace Formats

The CE demo uses a simple internal JSON format for maximum portability. Example:

```json
{
  "spans": [
    {
      "name": "createOrder",
      "service": "orders",
      "startNanos": 1693910000000000000,
      "endNanos": 1693910000100000000,
      "attributes": {
        "http.status_code": 201,
        "response.body": {"id": "ORD-1"}
      }
    }
  ]
}
```

We also include Jaeger/OTLP-style samples for reference.

## How Traces Are Used

1. Contract Discovery: `choreoatlas spec discover` generates FlowSpec + ServiceSpec.
2. Choreography Validation: `choreoatlas run validate` checks semantics, temporal ordering, and causality.
3. Reporting: HTML/JUnit/JSON outputs for humans and CI systems.

## Real-World Usage

- Export traces from Jaeger/Zipkin/OTLP, convert or map to the internal format.
- Gate deployments by running `choreoatlas ci-gate` in CI.
- Record baselines to track coverage/conditions over time.
