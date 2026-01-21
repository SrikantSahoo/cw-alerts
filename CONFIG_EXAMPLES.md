# Configuration Examples

This document contains real-world configuration examples for different AWS service setups.

## Example 1: ALB Configuration

### Find Your Load Balancer Details

```bash
# List all load balancers
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' --output table

# Example output:
# | my-alb | arn:aws:elasticloadbalancing:ap-southeast-2:123456789:loadbalancer/app/my-alb/50dc6c495c0c9bda |
```

### Update Configuration

**File: `infra/config/dev/alb-5xx-alerts.yaml`**

```yaml
template:
  path: alb-5xx-alerts.yaml
  type: file

parameters:
  LoadBalancerName: my-alb
  LoadBalancerArn: arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/my-alb/50dc6c495c0c9bda
  AlarmThreshold: 10
  EvaluationPeriods: 1
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

## Example 2: DynamoDB Configuration

### Find Your Table Name

```bash
# List all DynamoDB tables
aws dynamodb list-tables

# Example output:
# {
#     "TableNames": [
#         "users-table",
#         "orders-table"
#     ]
# }
```

### Update Configuration

**File: `infra/config/dev/dynamodb-alerts.yaml`**

```yaml
template:
  path: dynamodb-alerts.yaml
  type: file

parameters:
  TableName: users-table
  AlarmThreshold: 100
  EvaluationPeriods: 2
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

### For Tables with Global Secondary Indexes (GSI)

If you need to monitor specific GSI:

```yaml
# Modify template to include GSI dimensions:
# Dimensions:
#   - Name: TableName
#     Value: !Ref TableName
#   - Name: GlobalSecondaryIndexName
#     Value: your-gsi-name
```

## Example 3: ECS Configuration

### Find Your Cluster and Service

```bash
# List all ECS clusters
aws ecs list-clusters

# List services in a cluster
aws ecs list-services --cluster my-cluster

# Get service details
aws ecs describe-services --cluster my-cluster --services my-service
```

### Update Configuration

**File: `infra/config/dev/ecs-5xx-alerts.yaml`**

```yaml
template:
  path: ecs-5xx-alerts.yaml
  type: file

parameters:
  ClusterName: my-cluster
  ServiceName: my-service
  AlarmThreshold: 5
  EvaluationPeriods: 1
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

### For Multiple Services

Create separate config files for each service:

**File: `infra/config/dev/ecs-api-service-alerts.yaml`**
```yaml
template:
  path: ecs-5xx-alerts.yaml
  type: file

parameters:
  ClusterName: my-cluster
  ServiceName: api-service
  AlarmThreshold: 5
  EvaluationPeriods: 1
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

**File: `infra/config/dev/ecs-worker-service-alerts.yaml`**
```yaml
template:
  path: ecs-5xx-alerts.yaml
  type: file

parameters:
  ClusterName: my-cluster
  ServiceName: worker-service
  AlarmThreshold: 10
  EvaluationPeriods: 2
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

## Example 4: SQS Configuration

### Find Your Queue Name

```bash
# List all SQS queues
aws sqs list-queues

# Get queue attributes
aws sqs get-queue-attributes \
  --queue-url https://sqs.ap-southeast-2.amazonaws.com/123456789012/my-queue \
  --attribute-names All
```

### Update Configuration

**File: `infra/config/dev/sqs-alerts.yaml`**

```yaml
template:
  path: sqs-alerts.yaml
  type: file

parameters:
  QueueName: my-queue
  AlarmThreshold: 50
  EvaluationPeriods: 2
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

### For Queue with Dead Letter Queue (DLQ)

```yaml
# The template automatically monitors the DLQ:
# Dimensions:
#   - Name: QueueName
#     Value: !Sub '${QueueName}-dlq'
```

## Example 5: Production Environment Setup

### Directory Structure
```
infra/
├── config/
│   ├── config.yaml
│   ├── dev/
│   │   ├── sns-topic.yaml
│   │   ├── alb-5xx-alerts.yaml
│   │   ├── dynamodb-alerts.yaml
│   │   ├── ecs-5xx-alerts.yaml
│   │   └── sqs-alerts.yaml
│   └── prod/
│       ├── sns-topic.yaml
│       ├── alb-5xx-alerts.yaml
│       ├── dynamodb-alerts.yaml
│       ├── ecs-5xx-alerts.yaml
│       └── sqs-alerts.yaml
└── templates/
    ├── sns-topic.yaml
    ├── alb-5xx-alerts.yaml
    ├── dynamodb-alerts.yaml
    ├── ecs-5xx-alerts.yaml
    └── sqs-alerts.yaml
```

### Production SNS Configuration

**File: `infra/config/prod/sns-topic.yaml`**

```yaml
template:
  path: sns-topic.yaml
  type: file

parameters:
  EmailAddress: devops-team@company.com
  TopicName: cw-alerts-prod
```

### Production ALB Configuration

**File: `infra/config/prod/alb-5xx-alerts.yaml`**

```yaml
template:
  path: alb-5xx-alerts.yaml
  type: file

parameters:
  LoadBalancerName: prod-alb
  LoadBalancerArn: arn:aws:elasticloadbalancing:ap-southeast-2:123456789012:loadbalancer/app/prod-alb/abcd1234ef567890
  AlarmThreshold: 5          # Lower threshold for production
  EvaluationPeriods: 1
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

### Production ECS Configuration with Multiple Services

**File: `infra/config/prod/ecs-api-alerts.yaml`**

```yaml
template:
  path: ecs-5xx-alerts.yaml
  type: file

parameters:
  ClusterName: prod-cluster
  ServiceName: api-service
  AlarmThreshold: 2          # Very strict for production
  EvaluationPeriods: 1
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

**File: `infra/config/prod/ecs-worker-alerts.yaml`**

```yaml
template:
  path: ecs-5xx-alerts.yaml
  type: file

parameters:
  ClusterName: prod-cluster
  ServiceName: worker-service
  AlarmThreshold: 5
  EvaluationPeriods: 2
  SnsTopicArn: !stack_output sns-topic.yaml::SNSTopicArn
```

## Example 6: Deployment Commands

### Deploy Development Environment
```bash
cd infra
sceptre launch -y dev
```

### Deploy Production Environment
```bash
cd infra
sceptre launch -y prod
```

### Deploy Single Service in Production
```bash
cd infra
sceptre launch -y prod/sns-topic.yaml
sceptre launch -y prod/alb-5xx-alerts.yaml
```

### Update Specific Alarm Threshold
```bash
# Edit the configuration file
vi infra/config/prod/alb-5xx-alerts.yaml

# Change AlarmThreshold to new value, then:
cd infra
sceptre update prod/alb-5xx-alerts.yaml
```

## Example 7: Complex Scenario - Multi-Region Setup

### Directory Structure
```
infra/
├── config/
│   ├── config.yaml            # Primary region (ap-southeast-2)
│   ├── dev/
│   │   └── *.yaml
│   └── prod/
│       └── *.yaml
└── config-us/
    ├── config.yaml            # Secondary region (us-east-1)
    ├── dev/
    │   └── *.yaml
    └── prod/
        └── *.yaml
```

### Primary Region Config
**File: `infra/config/config.yaml`**
```yaml
project_code: cw-alerts
region: ap-southeast-2
```

### Secondary Region Config
**File: `infra/config-us/config.yaml`**
```yaml
project_code: cw-alerts-us
region: us-east-1
```

### Deployment
```bash
# Deploy to primary region
cd infra
sceptre launch -y prod

# Deploy to secondary region
cd config-us
sceptre launch -y prod
```

## Retrieving Configuration Values

### Get Email from SNS Subscription
```bash
SNS_TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name cw-alerts-dev-sns-topic \
  --query 'Stacks[0].Outputs[?OutputKey==`SNSTopicArn`].OutputValue' \
  --output text)

aws sns list-subscriptions-by-topic --topic-arn "$SNS_TOPIC_ARN"
```

### Generate Configuration from Existing Resources
```bash
#!/bin/bash

# Get ALB info
ALB_ARN=$(aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[0].LoadBalancerArn' \
  --output text)
ALB_NAME=$(aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[0].LoadBalancerName' \
  --output text)

echo "LoadBalancerName: $ALB_NAME"
echo "LoadBalancerArn: $ALB_ARN"
```

## Next Steps

1. Copy example configurations to your environment
2. Update resource names and ARNs
3. Adjust thresholds based on your baseline metrics
4. Deploy and test
5. Monitor alarms in CloudWatch console
6. Fine-tune thresholds based on actual performance
