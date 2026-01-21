#!/bin/bash

# CloudWatch Alerts Deployment Script
# This script deploys all CloudWatch alert stacks using Sceptre

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/infra"
ENVIRONMENT="${1:-dev}"

echo "=========================================="
echo "CloudWatch Alerts Deployment"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo "Region: ap-southeast-2"
echo ""

# Check if Sceptre is installed
if ! command -v sceptre &> /dev/null; then
    echo "Error: Sceptre is not installed"
    echo "Install with: pip install sceptre"
    exit 1
fi

# Check if AWS CLI is configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "Error: AWS credentials not configured"
    exit 1
fi

echo "Deploying stacks in order..."
echo ""

cd "$INFRA_DIR"

# Deploy SNS topic first (dependency)
echo "[1/5] Deploying SNS Topic..."
sceptre launch -y "$ENVIRONMENT/sns-topic.yaml"
echo "✓ SNS Topic deployed"
echo ""

# Deploy ALB alerts
echo "[2/5] Deploying ALB 5XX Alerts..."
sceptre launch -y "$ENVIRONMENT/alb-5xx-alerts.yaml"
echo "✓ ALB alerts deployed"
echo ""

# Deploy DynamoDB alerts
echo "[3/5] Deploying DynamoDB Alerts..."
sceptre launch -y "$ENVIRONMENT/dynamodb-alerts.yaml"
echo "✓ DynamoDB alerts deployed"
echo ""

# Deploy ECS alerts
echo "[4/5] Deploying ECS 5XX Alerts..."
sceptre launch -y "$ENVIRONMENT/ecs-5xx-alerts.yaml"
echo "✓ ECS alerts deployed"
echo ""

# Deploy SQS alerts
echo "[5/5] Deploying SQS Alerts..."
sceptre launch -y "$ENVIRONMENT/sqs-alerts.yaml"
echo "✓ SQS alerts deployed"
echo ""

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Next Steps:"
echo "1. Check your email for SNS subscription confirmation"
echo "2. Click the confirmation link to enable alerts"
echo "3. View alarms: sceptre list outputs $ENVIRONMENT"
echo ""
