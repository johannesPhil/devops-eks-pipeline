#!/bin/bash
# Manual deployment script for InnovateMart retail-store-sample-app
# For testing and assessment purposes

set -e

echo "🚀 Deploying InnovateMart Retail Store to EKS..."

# Check if kubectl is configured
if ! kubectl get nodes &>/dev/null; then
    echo "❌ kubectl is not configured or cluster is not accessible"
    echo "Run: aws eks update-kubeconfig --region us-east-1 --name innovatemart-cluster"
    exit 1
fi

echo "✅ Cluster connection verified"

# Deploy AWS auth for developer user
echo "🔐 Configuring AWS auth..."
kubectl apply -f k8s/aws-auth.yaml

# Deploy databases first
echo "🗄️  Deploying in-cluster databases..."
kubectl apply -f k8s/retail-store/databases.yaml

echo "⏳ Waiting for databases to be ready..."
kubectl rollout status deployment/catalog-db --timeout=300s
kubectl rollout status deployment/orders-db --timeout=300s
kubectl rollout status deployment/carts-dynamodb --timeout=300s
kubectl rollout status deployment/redis --timeout=300s
kubectl rollout status deployment/rabbitmq --timeout=300s

# Deploy applications
echo "🛍️  Deploying retail store applications..."
kubectl apply -f k8s/retail-store/applications.yaml

echo "⏳ Waiting for applications to be ready..."
kubectl rollout status deployment/catalog --timeout=300s
kubectl rollout status deployment/carts --timeout=300s
kubectl rollout status deployment/orders --timeout=300s
kubectl rollout status deployment/checkout --timeout=300s
kubectl rollout status deployment/ui --timeout=300s

# Show status
echo ""
echo "📊 DEPLOYMENT STATUS:"
echo "===================="
kubectl get nodes
echo ""
kubectl get pods --all-namespaces
echo ""
kubectl get services

# Get LoadBalancer URL
echo ""
echo "🌐 APPLICATION ACCESS:"
echo "====================="
echo "Getting LoadBalancer URL for UI service..."

# Wait for external IP
external_ip=""
while [ -z $external_ip ]; do
    echo "⏳ Waiting for external IP..."
    external_ip=$(kubectl get service ui --template="{{range .status.loadBalancer.ingress}}{{.hostname}}{{end}}")
    [ -z "$external_ip" ] && sleep 10
done

echo "✅ Retail Store is accessible at: http://$external_ip"
echo ""
echo "🎯 ASSESSMENT COMPLETE!"
echo "The InnovateMart retail-store-sample-app is now running on EKS"

# Resource usage summary
echo ""
echo "📈 RESOURCE USAGE SUMMARY:"
echo "========================="
echo "Databases: MySQL, PostgreSQL, DynamoDB Local, Redis, RabbitMQ"
echo "Applications: Catalog, Cart, Orders, Checkout, UI"
echo "Total containers: ~10 running on single t3.micro node"
echo "Optimized for assessment with minimal resource limits"