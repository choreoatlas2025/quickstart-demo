# Sample Traces

This directory contains pre-recorded trace data for the ChoreoAtlas CLI quickstart demo.

## Trace Files

### `successful-order.json`
**Happy Path Scenario**: Complete e-commerce order flow
- **Flow**: Catalogue Browse → Add to Cart → Create Order → Payment Authorization → Shipping
- **Services**: catalogue, cart, orders, payment, shipping
- **Result**: ✅ All services respond successfully
- **Duration**: ~280ms total execution time
- **Use Case**: Validate normal choreography flow

### `failed-payment.json` 
**Error Scenario**: Order fails due to payment decline
- **Flow**: Catalogue Browse → Add to Cart → Create Order → Payment Decline
- **Services**: catalogue, cart, orders, payment
- **Result**: ❌ Payment service returns 402 (insufficient funds)
- **Duration**: ~150ms (shorter due to early termination)
- **Use Case**: Validate error handling and circuit breaker patterns

## Trace Format

These traces follow the **OpenTelemetry/Jaeger JSON format**:

```json
{
  "traceID": "unique-trace-identifier",
  "spans": [
    {
      "traceID": "matching-trace-id", 
      "spanID": "unique-span-id",
      "parentSpanID": "parent-span-id",
      "operationName": "HTTP method + endpoint",
      "startTime": "microseconds since epoch",
      "duration": "span duration in microseconds",
      "tags": {
        "http.method": "GET|POST|PUT|DELETE",
        "http.url": "full request URL",
        "http.status_code": "HTTP response code",
        "component": "service identifier"
      },
      "process": {
        "serviceName": "microservice name",
        "tags": {
          "hostname": "container/pod identifier"
        }
      },
      "logs": [
        {
          "timestamp": "log timestamp",
          "fields": {
            "event": "business event name",
            "key": "value pairs"
          }
        }
      ]
    }
  ]
}
```

## How Traces Are Used

1. **Contract Discovery**: `choreoatlas discover` analyzes these traces to generate:
   - **ServiceSpec files** (.servicespec.yaml) for each service
   - **FlowSpec files** (.flowspec.yaml) for orchestration flows

2. **Choreography Validation**: `choreoatlas validate` checks:
   - Service-level semantic contracts (preconditions/postconditions)
   - Temporal ordering of service calls
   - Causal relationships and dependencies  
   - Error propagation patterns

3. **Compliance Reporting**: HTML reports show:
   - Contract adherence per service
   - Flow execution timeline
   - Error analysis and coverage metrics

## Real-World Usage

In production, you would:

1. **Export from APM**: Extract traces from Jaeger, Zipkin, or OTLP exporters
2. **Filter by Business Flow**: Focus on critical user journeys
3. **Continuous Validation**: Run `choreoatlas validate` in CI/CD pipelines
4. **Baseline Establishment**: Track contract evolution over time

## Next Steps

- Run `make demo` to see these traces in action
- Compare successful vs failed scenarios in generated reports
- Try capturing your own traces with `docker-compose --profile load-test up`