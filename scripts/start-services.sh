#!/bin/bash
set -e

echo "🐳 Starting Sock Shop microservices for live demo..."

# Check Docker availability
if ! command -v docker &> /dev/null; then
    echo "❌ Docker not found. Please install Docker Desktop."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose not found. Please install Docker Compose."
    exit 1
fi

echo "🚀 Starting services with Docker Compose..."
docker-compose up -d

echo "⏳ Waiting for services to be healthy..."
sleep 15

# Health check function
check_service() {
    local service_name=$1
    local port=$2
    local path=${3:-"/health"}
    
    echo "🔍 Checking $service_name at localhost:$port$path..."
    if curl -f "http://localhost:$port$path" &>/dev/null; then
        echo "✅ $service_name is healthy"
        return 0
    else
        echo "⚠️  $service_name is not ready yet"
        return 1
    fi
}

# Wait for key services to be ready
echo ""
echo "🏥 Performing health checks..."

# Frontend (main entry point)
for i in {1..10}; do
    if check_service "frontend" "8080" "/"; then
        break
    fi
    if [ $i -eq 10 ]; then
        echo "❌ Frontend failed to start after 10 attempts"
        docker-compose logs frontend
        exit 1
    fi
    sleep 3
done

# Check other services
for service_port in "catalogue:8081" "cart:8082" "orders:8083" "payment:8085"; do
    IFS=':' read -r service port <<< "$service_port"
    check_service "$service" "$port" "/" || echo "⚠️  $service may need more time"
done

echo ""
echo "✅ Core services are running!"
echo ""
echo "🌐 Available endpoints:"
echo "   • Frontend:  http://localhost:8080"
echo "   • Catalogue: http://localhost:8081/catalogue"
echo "   • Cart:      http://localhost:8082/carts"
echo "   • Orders:    http://localhost:8083/orders" 
echo "   • Payment:   http://localhost:8085/paymentAuth"
echo "   • Zipkin:    http://localhost:9411 (tracing UI)"
echo ""
echo "💡 Tip: Visit http://localhost:8080 to interact with the Sock Shop"
echo "💡 Tip: Use 'docker-compose logs [service]' to view service logs"
echo ""
echo "🔥 To generate traces, run: docker-compose --profile load-test up loadgen"