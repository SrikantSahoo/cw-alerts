# CloudWatch Alerts Infrastructure - Getting Started

## 📋 Overview

This repository contains a complete, production-ready CloudWatch alerts infrastructure using Sceptre and CloudFormation. It monitors 5XX errors across 4 AWS services with email notifications.

## ✨ Features

- **5 AWS Services Monitored:**
  - ✅ ALB (Application Load Balancer) - Target and ELB 5XX errors
  - ✅ DynamoDB - System errors and capacity warnings
  - ✅ ECS - Task failures, resource constraints, application errors
  - ✅ SQS - Dead letter queue messages and processing delays
  - ✅ SNS - Email notifications for all alarms

- **Infrastructure as Code:**
  - Sceptre-based configuration
  - CloudFormation templates
  - Multi-environment support (dev, staging, prod)
  - Easy parameter customization

- **Email Notifications:**
  - Automatic SNS email subscriptions
  - Confirmation-based subscription system
  - Works across all alarm types

## 📁 Directory Structure

```
cw-alerts/
├── infra/
│   ├── config/
│   │   ├── config.yaml                 # Main Sceptre config
│   │   └── dev/                        # Dev environment configs
│   │       ├── sns-topic.yaml
│   │       ├── alb-5xx-alerts.yaml
│   │       ├── dynamodb-alerts.yaml
│   │       ├── ecs-5xx-alerts.yaml
│   │       └── sqs-alerts.yaml
│   └── templates/                      # CloudFormation templates
│       ├── sns-topic.yaml
│       ├── alb-5xx-alerts.yaml
│       ├── dynamodb-alerts.yaml
│       ├── ecs-5xx-alerts.yaml
│       └── sqs-alerts.yaml
├── deploy.sh                           # Deployment automation
├── cleanup.sh                          # Cleanup automation
├── README.md                           # Full documentation
├── QUICKREF.md                         # Quick reference guide
├── CONFIG_EXAMPLES.md                  # Configuration examples
└── DEPLOYMENT.md                       # This file
```

## 🚀 Quick Start (5 minutes)

### 1. Install Sceptre

```bash
pip install sceptre
```

### 2. Configure Email Address

Edit `infra/config/dev/sns-topic.yaml`:

```yaml
parameters:
  EmailAddress: your-email@example.com  # Change this
  TopicName: cw-alerts-dev
```

### 3. Configure Service Details

Update each service config file with your actual AWS resource names/ARNs:

```bash
# Edit ALB configuration
vi infra/config/dev/alb-5xx-alerts.yaml

# Edit DynamoDB configuration  
vi infra/config/dev/dynamodb-alerts.yaml

# Edit ECS configuration
vi infra/config/dev/ecs-5xx-alerts.yaml

# Edit SQS configuration
vi infra/config/dev/sqs-alerts.yaml
```

### 4. Deploy

```bash
# Option A: Using the deployment script
./deploy.sh dev

# Option B: Using Sceptre directly
cd infra
sceptre launch -y dev
```

### 5. Confirm Email Subscription

Check your email for AWS SNS confirmation. Click the link to enable alerts.

## 📊 Alarms Created

### ALB Alerts
| Alarm | Metric | Threshold | Period |
|-------|--------|-----------|--------|
| Target 5XX Errors | HTTPCode_Target_5XX_Count | ≥ 10 | 60s |
| ELB 5XX Errors | HTTPCode_ELB_5XX_Count | ≥ 10 | 60s |
| Unhealthy Hosts | UnHealthyHostCount | > 0 | 300s |

### DynamoDB Alerts
| Alarm | Metric | Threshold | Period |
|-------|--------|-----------|--------|
| System Errors | SystemErrors | ≥ 100 | 60s |
| User Errors | UserErrors | ≥ 1000 | 60s |
| Write Capacity High | ConsumedWriteCapacityUnits | ≥ 80% | 300s |
| Read Capacity High | ConsumedReadCapacityUnits | ≥ 80% | 300s |

### ECS Alerts
| Alarm | Metric | Threshold | Period |
|-------|--------|-----------|--------|
| Task Failures | RunningCount | < 1 | 300s |
| High CPU | ContainerInstanceCpuUtilization | ≥ 85% | 300s |
| High Memory | ContainerInstanceMemoryUtilization | ≥ 85% | 300s |
| Unhealthy Tasks | HealthyTaskCount | < 1 | 300s |
| Application Errors | Errors (custom) | ≥ 5 | 300s |
| Task Count Low | RunningCount | < 1 | 60s |

### SQS Alerts
| Alarm | Metric | Threshold | Period |
|-------|--------|-----------|--------|
| DLQ Messages High | ApproximateNumberOfMessagesVisible | ≥ 50 | 300s |
| Queue Depth High | ApproximateNumberOfMessagesVisible | ≥ 1000 | 300s |
| Old Message Age | ApproximateAgeOfOldestMessage | ≥ 3600s | 300s |
| Message Spike | NumberOfMessagesSent | ≥ 10000 | 300s |
| Low Deletion Rate | NumberOfMessagesDeleted | < 1 | 300s |

## 🔧 Configuration Guide

### Getting Resource Identifiers

```bash
# ALB - Get LoadBalancer ARN
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' \
  --output table

# DynamoDB - List tables
aws dynamodb list-tables

# ECS - List clusters
aws ecs list-clusters

# ECS - List services in cluster
aws ecs list-services --cluster <cluster-name>

# SQS - List queues
aws sqs list-queues
```

### Customizing Thresholds

Edit the configuration files to adjust alarm thresholds based on your baseline metrics:

```yaml
parameters:
  AlarmThreshold: 10    # Change this value
  EvaluationPeriods: 1  # Or this
```

### Multi-Environment Setup

```bash
# Create staging environment
mkdir -p infra/config/staging
cp infra/config/dev/* infra/config/staging/
# Edit infra/config/staging/*.yaml

# Deploy to staging
cd infra
sceptre launch -y staging
```

## 📋 Common Tasks

### View All Alarms

```bash
aws cloudwatch describe-alarms --region ap-southeast-2
```

### Update Single Alarm

```bash
# Edit the configuration file
vi infra/config/dev/alb-5xx-alerts.yaml

# Update the stack
cd infra
sceptre update dev/alb-5xx-alerts.yaml
```

### Test Alert Notification

```bash
# Get SNS topic ARN
TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name cw-alerts-dev-sns-topic \
  --query 'Stacks[0].Outputs[0].OutputValue' \
  --output text)

# Send test message
aws sns publish \
  --topic-arn "$TOPIC_ARN" \
  --subject "Test Alert" \
  --message "This is a test message"
```

### List Deployed Stacks

```bash
cd infra
sceptre list outputs dev
```

### Delete All Alarms

```bash
./cleanup.sh dev
```

## 🐛 Troubleshooting

### Alarm Not Triggering
- Check CloudWatch metrics are being published
- Verify alarm threshold makes sense for your metrics
- Check SNS topic has active subscriptions
- Confirm email subscription was confirmed

### SNS Email Not Received
- Check spam/junk folder
- Verify email address in configuration
- Check SNS subscription status: `aws sns list-subscriptions`
- Resend subscription confirmation from SNS console

### Sceptre Connection Error
- Verify AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for CloudFormation, CloudWatch, SNS
- Ensure region is correct: `echo $AWS_REGION`

### Template Validation Error
- Validate template: `cd infra && sceptre validate dev`
- Check YAML syntax in configuration files
- Ensure all required parameters are provided

## 📚 Documentation

- **[README.md](README.md)** - Complete documentation
- **[QUICKREF.md](QUICKREF.md)** - Quick reference guide
- **[CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md)** - Configuration examples

## 🔐 Security Considerations

- ✅ Email subscriptions require confirmation
- ✅ SNS topic uses encryption at rest
- ✅ IAM roles should be restricted to necessary permissions
- ✅ Consider using Organization SCPs for compliance
- ✅ Enable CloudTrail for audit logging

## 💰 Cost Estimation

| Component | Cost | Notes |
|-----------|------|-------|
| CloudWatch Alarms | $0.10/alarm/month | 18 alarms = $1.80/month |
| SNS Topic | Free | Up to 1,000 notifications/month free |
| SNS Email | $2/100,000 notifications | Most companies < $1/month |
| Total | ~$2-5/month | Very cost-effective |

## 🚢 Production Deployment

1. Create `prod` environment configuration
2. Update all resource identifiers for production
3. Adjust alarm thresholds based on production baselines
4. Deploy with additional review
5. Monitor for 24-48 hours
6. Tune thresholds as needed

## 📞 Support Resources

- AWS CloudWatch: https://docs.aws.amazon.com/cloudwatch/
- Sceptre: https://sceptre.cloudreach.com/
- CloudFormation: https://docs.aws.amazon.com/cloudformation/
- SNS: https://docs.aws.amazon.com/sns/

## 📝 License

This infrastructure is provided as-is. Modify and use as needed for your organization.

---

**Ready to deploy?** Start with: `./deploy.sh dev`
