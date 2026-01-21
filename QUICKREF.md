# Quick Reference Guide for CloudWatch Alerts

## Installation

```bash
# Install Sceptre
pip install sceptre

# Verify installation
sceptre --version
```

## Common Sceptre Commands

### Deployment
```bash
# Deploy all stacks for an environment
sceptre launch -y dev

# Deploy single stack
sceptre launch -y dev/sns-topic.yaml

# Deploy with verbose output
sceptre launch -v dev/sns-topic.yaml
```

### View Status
```bash
# List all stacks in an environment
sceptre list outputs dev

# Show stack details
sceptre describe dev/alb-5xx-alerts.yaml

# Check stack status
sceptre status dev
```

### Updates
```bash
# Update a specific stack
sceptre update dev/alb-5xx-alerts.yaml

# Update all stacks
sceptre update dev
```

### Delete
```bash
# Delete single stack
sceptre delete -y dev/sqs-alerts.yaml

# Delete all stacks
sceptre delete -y dev
```

### Debugging
```bash
# Validate templates
sceptre validate dev

# Show generated template
sceptre generate dev/alb-5xx-alerts.yaml

# List template dependencies
sceptre list dependencies dev
```

## Quick Setup

1. **Update email in SNS config**
   ```bash
   vi infra/config/dev/sns-topic.yaml
   # Change EmailAddress parameter
   ```

2. **Update service names/ARNs**
   ```bash
   vi infra/config/dev/alb-5xx-alerts.yaml
   vi infra/config/dev/dynamodb-alerts.yaml
   vi infra/config/dev/ecs-5xx-alerts.yaml
   vi infra/config/dev/sqs-alerts.yaml
   ```

3. **Deploy**
   ```bash
   ./deploy.sh dev
   ```

4. **Confirm email subscription**
   - Check email for AWS notification
   - Click confirmation link

5. **Verify deployment**
   ```bash
   sceptre list outputs dev
   ```

## Parameter Guide

### ALB Alerts
- **LoadBalancerName**: Name visible in AWS Console
- **LoadBalancerArn**: Full ARN (arn:aws:elasticloadbalancing:...)
- **AlarmThreshold**: Number of 5XX errors before alert (default: 10)

### DynamoDB Alerts
- **TableName**: Exact DynamoDB table name
- **AlarmThreshold**: Number of system errors (default: 100)

### ECS Alerts
- **ClusterName**: ECS cluster name
- **ServiceName**: ECS service name
- **AlarmThreshold**: Error count threshold (default: 5)

### SQS Alerts
- **QueueName**: SQS queue name
- **AlarmThreshold**: DLQ message count (default: 50)

## Testing Alerts

### Send Test Notification
```bash
aws sns publish \
  --topic-arn arn:aws:sns:ap-southeast-2:ACCOUNT_ID:cw-alerts-dev \
  --subject "Test CloudWatch Alert" \
  --message "This is a test message from CloudWatch Alerts infrastructure"
```

### Simulate Alarm Trigger
```bash
# Get alarm name
ALARM_NAME=$(aws cloudwatch describe-alarms \
  --query "Alarms[0].AlarmName" \
  --output text)

# Set to ALARM state
aws cloudwatch set-alarm-state \
  --alarm-name "$ALARM_NAME" \
  --state-value ALARM \
  --state-reason "Testing alert mechanism"
```

## Accessing CloudWatch Console

```bash
# Direct link to CloudWatch Alarms
# https://console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#alarmsV2:
```

## Troubleshooting

### Check SNS Subscription Status
```bash
aws sns list-subscriptions-by-topic \
  --topic-arn arn:aws:sns:ap-southeast-2:ACCOUNT_ID:cw-alerts-dev
```

### View Recent Alarm Activity
```bash
aws cloudwatch describe-alarm-history \
  --max-records 10
```

### Get Specific Alarm Details
```bash
aws cloudwatch describe-alarms \
  --alarm-names "ALB-my-alb-5XX-Errors-High"
```

## Environment-Specific Deployments

### Development
```bash
sceptre launch -y dev
```

### Staging
```bash
mkdir -p infra/config/staging
cp infra/config/dev/* infra/config/staging/
# Edit parameters in staging files
sceptre launch -y staging
```

### Production
```bash
mkdir -p infra/config/prod
cp infra/config/dev/* infra/config/prod/
# Edit parameters in prod files
sceptre launch -y prod
```

## Cost Optimization

- CloudWatch Alarms: $0.10 per alarm per month
- SNS: Free tier includes 1000 notifications/month
- Estimated cost for complete setup: ~$5-10/month

## Additional Resources

- AWS CloudWatch Documentation: https://docs.aws.amazon.com/cloudwatch/
- Sceptre Documentation: https://sceptre.cloudreach.com/
- AWS CloudFormation Best Practices: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html
