#!/bin/bash

# CloudWatch Alerts Cleanup Script
# This script removes all CloudWatch alert stacks using Sceptre

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INFRA_DIR="${SCRIPT_DIR}/infra"
ENVIRONMENT="${1:-dev}"

echo "=========================================="
echo "CloudWatch Alerts Cleanup"
echo "=========================================="
echo "Environment: $ENVIRONMENT"
echo ""
echo "WARNING: This will delete all CloudWatch alert stacks!"
read -p "Continue? (yes/no): " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled"
    exit 1
fi

cd "$INFRA_DIR"

# Delete in reverse order (dependencies first)
echo "Deleting stacks..."
echo ""

echo "[1/5] Deleting ECS Alerts..."
sceptre delete -y "$ENVIRONMENT/ecs-5xx-alerts.yaml" 2>/dev/null || true
echo "✓ ECS alerts deleted"
echo ""

echo "[2/5] Deleting SQS Alerts..."
sceptre delete -y "$ENVIRONMENT/sqs-alerts.yaml" 2>/dev/null || true
echo "✓ SQS alerts deleted"
echo ""

echo "[3/5] Deleting DynamoDB Alerts..."
sceptre delete -y "$ENVIRONMENT/dynamodb-alerts.yaml" 2>/dev/null || true
echo "✓ DynamoDB alerts deleted"
echo ""

echo "[4/5] Deleting ALB Alerts..."
sceptre delete -y "$ENVIRONMENT/alb-5xx-alerts.yaml" 2>/dev/null || true
echo "✓ ALB alerts deleted"
echo ""

echo "[5/5] Deleting SNS Topic..."
sceptre delete -y "$ENVIRONMENT/sns-topic.yaml" 2>/dev/null || true
echo "✓ SNS Topic deleted"
echo ""

echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
