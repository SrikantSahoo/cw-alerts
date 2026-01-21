# CloudWatch Alerts Infrastructure with Sceptre

This directory contains Sceptre configurations and CloudFormation templates for AWS CloudWatch alerts monitoring 5XX errors across multiple AWS services.

## Directory Structure

```
infra/
├── config/
│   ├── config.yaml                 # Main Sceptre configuration
│   └── dev/                        # Environment-specific configurations
│       ├── sns-topic.yaml
│       ├── alb-5xx-alerts.yaml
│       ├── dynamodb-alerts.yaml
│       ├── ecs-5xx-alerts.yaml
│       └── sqs-alerts.yaml
└── templates/
    ├── sns-topic.yaml              # SNS Topic CloudFormation template
    ├── alb-5xx-alerts.yaml         # ALB 5XX errors CloudFormation template
    ├── dynamodb-alerts.yaml        # DynamoDB system errors CloudFormation template
    ├── ecs-5xx-alerts.yaml         # ECS services CloudFormation template
    └── sqs-alerts.yaml             # SQS queue CloudFormation template
```

## Services Monitored

### 1. **ALB (Application Load Balancer)**
- **HTTPCode_Target_5XX_Count**: 5XX errors from target instances
- **HTTPCode_ELB_5XX_Count**: 5XX errors from ELB itself
- **UnHealthyHostCount**: Number of unhealthy targets

### 2. **DynamoDB**
- **SystemErrors**: Server-side errors (5XX equivalent)
- **UserErrors**: Client-side errors (4XX equivalent)
- **ConsumedWriteCapacityUnits**: Write capacity monitoring
- **ConsumedReadCapacityUnits**: Read capacity monitoring

### 3. **ECS Services**
- **RunningCount**: Task count monitoring
- **ContainerInstanceCpuUtilization**: CPU usage (cause of 5XX errors)
- **ContainerInstanceMemoryUtilization**: Memory usage (cause of 5XX errors)
- **HealthyTaskCount**: Task health status
- **Application Errors**: Custom metric from logs
- **Task Count**: Scaling events

### 4. **SQS**
- **DeadLetterQueue Messages**: Messages failing to process (5XX equivalent)
- **Queue Depth**: Message queue size
- **Oldest Message Age**: Message processing delays
- **Messages Sent**: Volume monitoring
- **Messages Deleted**: Processing success rate

## Prerequisites

1. **Sceptre** installed (v2.7+)
   ```bash
   pip install sceptre
   ```

2. **AWS CLI** configured with appropriate credentials

3. **Email address** for SNS notifications

## Configuration

### Update Parameters

Before deployment, update the parameter files under `infra/config/dev/`:

#### SNS Topic (`sns-topic.yaml`)
```yaml
parameters:
  EmailAddress: your-email@example.com  # Update this
  TopicName: cw-alerts-dev
```

#### ALB Alerts (`alb-5xx-alerts.yaml`)
```yaml
parameters:
  LoadBalancerName: my-alb              # Your ALB name
  LoadBalancerArn: arn:aws:elasticloadbalancing:...  # Your ALB ARN
  AlarmThreshold: 10
  EvaluationPeriods: 1
```

#### DynamoDB Alerts (`dynamodb-alerts.yaml`)
```yaml
parameters:
  TableName: my-table                   # Your table name
  AlarmThreshold: 100
```

#### ECS Alerts (`ecs-5xx-alerts.yaml`)
```yaml
parameters:
  ClusterName: my-cluster               # Your cluster name
  ServiceName: my-service               # Your service name
  AlarmThreshold: 5
```

#### SQS Alerts (`sqs-alerts.yaml`)
```yaml
parameters:
  QueueName: my-queue                   # Your queue name
  AlarmThreshold: 50
```

## Deployment

### Deploy All Stacks
```bash
cd infra
sceptre launch -y dev
```

### Deploy Specific Service Stack
```bash
# Deploy SNS topic first
sceptre launch -y dev/sns-topic.yaml

# Deploy ALB alerts
sceptre launch -y dev/alb-5xx-alerts.yaml

# Deploy DynamoDB alerts
sceptre launch -y dev/dynamodb-alerts.yaml

# Deploy ECS alerts
sceptre launch -y dev/ecs-5xx-alerts.yaml

# Deploy SQS alerts
sceptre launch -y dev/sqs-alerts.yaml
```

### Deployment Order
1. **SNS Topic** - Must be created first (other stacks depend on it)
2. **Service-specific alerts** - Can be deployed in any order after SNS topic

## Verification

### Check Deployed Stacks
```bash
sceptre list outputs dev
```

### View Alarms in AWS Console
```bash
aws cloudwatch describe-alarms --region ap-southeast-2
```

### Test SNS Notification
```bash
# Replace with actual SNS topic ARN
aws sns publish \
  --topic-arn arn:aws:sns:ap-southeast-2:ACCOUNT_ID:cw-alerts-dev \
  --subject "Test Alert" \
  --message "This is a test message"
```

## Email Subscription

After deployment, you'll receive an email from AWS SNS asking to confirm subscription. **Click the confirmation link** in the email to receive alerts.

## Updating Alarms

To modify alarm thresholds or parameters:

1. Update the corresponding YAML file under `infra/config/dev/`
2. Run the update command:
   ```bash
   sceptre update dev/<stack-name>.yaml
   ```

Example - Update ALB alarm threshold:
```bash
# Edit infra/config/dev/alb-5xx-alerts.yaml
# Change AlarmThreshold to desired value

sceptre update dev/alb-5xx-alerts.yaml
```

## Deletion

### Delete Specific Stack
```bash
sceptre delete -y dev/alb-5xx-alerts.yaml
```

### Delete All Stacks (Keep SNS for now)
```bash
sceptre delete -y dev/ecs-5xx-alerts.yaml
sceptre delete -y dev/dynamodb-alerts.yaml
sceptre delete -y dev/sqs-alerts.yaml
```

### Delete Everything (Including SNS)
```bash
sceptre delete -y dev
```

## Alarm Thresholds Reference

| Service | Metric | Default Threshold | Description |
|---------|--------|-------------------|-------------|
| ALB | Target 5XX Count | 10 | Sum over 60 seconds |
| ALB | ELB 5XX Count | 10 | Sum over 60 seconds |
| ALB | Unhealthy Hosts | > 0 | Average over 300 seconds |
| DynamoDB | System Errors | 100 | Sum over 60 seconds |
| DynamoDB | Write Capacity | 80 | Average over 300 seconds |
| ECS | Task Count | < 1 | Average over 60 seconds |
| ECS | CPU Utilization | 85% | Average over 300 seconds |
| ECS | Memory Utilization | 85% | Average over 300 seconds |
| SQS | DLQ Messages | 50 | Average over 300 seconds |
| SQS | Queue Depth | 1000 | Average over 300 seconds |
| SQS | Message Age | 3600 seconds | Maximum over 300 seconds |

## Environment Management

To create configurations for other environments (staging, production):

```bash
mkdir -p infra/config/prod

# Copy and modify dev configuration files for prod
cp infra/config/dev/*.yaml infra/config/prod/

# Update parameters in prod files
# Then deploy:
sceptre launch -y prod
```

## Metrics Used for 5XX Errors

- **ALB**: `HTTPCode_Target_5XX_Count`, `HTTPCode_ELB_5XX_Count`
- **DynamoDB**: `SystemErrors` (server-side failures)
- **ECS**: `Errors` (custom metric from logs), resource constraints (CPU/Memory)
- **SQS**: `DeadLetterQueue` messages (failed processing), processing delays

## Customization

### Adding Custom Metrics

Edit CloudFormation templates to add custom metrics:

1. Open the relevant template (e.g., `templates/ecs-5xx-alerts.yaml`)
2. Add new alarm resource following the same pattern
3. Update Sceptre config if needed
4. Deploy: `sceptre update dev/<stack-name>.yaml`

### Changing Alert Actions

Modify the `AlarmActions` section in templates to add:
- Additional SNS topics
- Lambda functions
- Auto Scaling actions
- Systems Manager actions

## Troubleshooting

### Alarm Not Triggering
- Verify metric data is being sent to CloudWatch
- Check alarm state in AWS Console
- Ensure threshold and comparison operator are correct
- Verify SNS topic permissions

### Missing Metrics
- Confirm CloudWatch agent is running on EC2 instances
- For ECS, enable CloudWatch Container Insights
- For custom metrics, ensure application is sending data

### SNS Not Sending Emails
- Confirm email subscription in SNS console
- Check email spam/junk folders
- Verify IAM permissions for SNS publish

## Support

For issues or questions:
1. Check CloudWatch Alarms in AWS Console
2. Review CloudWatch Logs
3. Verify IAM permissions
4. Check Sceptre logs: `sceptre launch -v dev`

## References

- [Sceptre Documentation](https://sceptre.cloudreach.com/)
- [AWS CloudWatch Alarms](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/)
- [AWS SNS Topics](https://docs.aws.amazon.com/sns/latest/dg/SNSGettingStarted.html)
