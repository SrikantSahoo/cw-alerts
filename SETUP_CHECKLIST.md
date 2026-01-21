# CloudWatch Alerts Infrastructure - Complete Setup

## 🎯 Project Overview

This is a **production-ready, enterprise-grade CloudWatch Alerts infrastructure** that monitors 5XX errors and related issues across AWS services with automated email notifications.

### What You Get

✅ **5 CloudFormation Templates** for comprehensive AWS service monitoring  
✅ **Sceptre Configuration** for multi-environment deployments  
✅ **18 CloudWatch Alarms** across 4 AWS services  
✅ **Automated Email Notifications** via SNS  
✅ **Deployment Automation Scripts** for easy setup  
✅ **Complete Documentation** and configuration examples  
✅ **Production-Ready Code** following AWS best practices  

---

## 📦 What's Included

### Directory Structure

```
cw-alerts/
├── infra/                          # Infrastructure code
│   ├── config/                     # Sceptre configuration
│   │   ├── config.yaml             # Main Sceptre config
│   │   └── dev/                    # Dev environment
│   │       ├── sns-topic.yaml      # SNS configuration
│   │       ├── alb-5xx-alerts.yaml
│   │       ├── dynamodb-alerts.yaml
│   │       ├── ecs-5xx-alerts.yaml
│   │       └── sqs-alerts.yaml
│   └── templates/                  # CloudFormation templates
│       ├── sns-topic.yaml
│       ├── alb-5xx-alerts.yaml
│       ├── dynamodb-alerts.yaml
│       ├── ecs-5xx-alerts.yaml
│       └── sqs-alerts.yaml
│
├── deploy.sh                       # Deploy all stacks
├── cleanup.sh                      # Delete all stacks
│
├── README.md                       # Full documentation
├── QUICKREF.md                     # Command reference
├── CONFIG_EXAMPLES.md              # Configuration examples
├── DEPLOYMENT.md                   # Getting started guide
├── SETUP_CHECKLIST.md              # This file
└── requirements.txt                # Python dependencies
```

---

## 📋 Setup Checklist

### Phase 1: Prerequisites ✓

- [ ] AWS Account with appropriate permissions
- [ ] AWS CLI installed and configured
- [ ] Python 3.7+ installed
- [ ] Internet connection for AWS API access

**Install AWS CLI:**
```bash
# macOS
brew install awscli

# Or visit: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html
```

### Phase 2: Install Sceptre ✓

- [ ] Install Sceptre
- [ ] Verify installation
- [ ] Test AWS credentials

**Installation:**
```bash
# Install from PyPI
pip install sceptre

# Install from requirements.txt
pip install -r requirements.txt

# Verify installation
sceptre --version
```

### Phase 3: Configure Email Notifications ✓

- [ ] Choose email address for alerts
- [ ] Update SNS configuration
- [ ] Prepare for email confirmation

**Edit Configuration:**
```bash
# Open the SNS configuration
vi infra/config/dev/sns-topic.yaml

# Update EmailAddress parameter:
# EmailAddress: your-email@example.com
```

### Phase 4: Gather AWS Resource Information ✓

For each service, collect the required information:

**ALB:**
```bash
aws elbv2 describe-load-balancers \
  --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' \
  --output table
```
- [ ] LoadBalancer Name
- [ ] LoadBalancer ARN

**DynamoDB:**
```bash
aws dynamodb list-tables
```
- [ ] Table Name(s)

**ECS:**
```bash
aws ecs list-clusters
aws ecs list-services --cluster <cluster-name>
```
- [ ] Cluster Name
- [ ] Service Name(s)

**SQS:**
```bash
aws sqs list-queues
```
- [ ] Queue Name(s)

### Phase 5: Update Configuration Files ✓

- [ ] Update `infra/config/dev/alb-5xx-alerts.yaml`
- [ ] Update `infra/config/dev/dynamodb-alerts.yaml`
- [ ] Update `infra/config/dev/ecs-5xx-alerts.yaml`
- [ ] Update `infra/config/dev/sqs-alerts.yaml`

**Example Update:**
```bash
# ALB Configuration
vi infra/config/dev/alb-5xx-alerts.yaml

# Update:
# LoadBalancerName: your-alb-name
# LoadBalancerArn: arn:aws:elasticloadbalancing:...
# AlarmThreshold: 10 (adjust as needed)
```

### Phase 6: Deploy Infrastructure ✓

- [ ] Validate configuration
- [ ] Deploy stacks
- [ ] Verify successful deployment

**Validate:**
```bash
cd infra
sceptre validate dev
```

**Deploy:**
```bash
cd infra
sceptre launch -y dev
# Or use the deployment script:
cd ..
./deploy.sh dev
```

### Phase 7: Verify Email Subscription ✓

- [ ] Check email inbox
- [ ] Click AWS SNS confirmation link
- [ ] Verify subscription is confirmed

**Check subscription status:**
```bash
aws sns list-subscriptions
```

### Phase 8: Test Alerts ✓

- [ ] Send test SNS notification
- [ ] Verify email is received
- [ ] Check CloudWatch Alarms console

**Send Test Message:**
```bash
TOPIC_ARN=$(aws cloudformation describe-stacks \
  --stack-name cw-alerts-dev-sns-topic \
  --query 'Stacks[0].Outputs[0].OutputValue' \
  --output text)

aws sns publish \
  --topic-arn "$TOPIC_ARN" \
  --subject "Test CloudWatch Alert" \
  --message "Test message to verify alerts are working"
```

### Phase 9: Fine-Tune Thresholds ✓

- [ ] Review baseline metrics
- [ ] Adjust alarm thresholds
- [ ] Update configurations
- [ ] Deploy updates

**Check Baseline Metrics:**
```bash
# ALB metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/ApplicationELB \
  --metric-name HTTPCode_Target_5XX_Count \
  --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 3600 \
  --statistics Average,Sum
```

### Phase 10: Documentation & Handoff ✓

- [ ] Share README with team
- [ ] Document alarm thresholds
- [ ] Create runbook for incident response
- [ ] Train team on monitoring

---

## 🚀 Quick Deployment (First Time)

```bash
# 1. Clone/navigate to project
cd cw-alerts

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure email
vi infra/config/dev/sns-topic.yaml
# Update: EmailAddress

# 4. Gather AWS resources
aws elbv2 describe-load-balancers --query 'LoadBalancers[*].[LoadBalancerName,LoadBalancerArn]' --output table
aws dynamodb list-tables
aws ecs list-clusters

# 5. Update configurations
vi infra/config/dev/alb-5xx-alerts.yaml
vi infra/config/dev/dynamodb-alerts.yaml
vi infra/config/dev/ecs-5xx-alerts.yaml
vi infra/config/dev/sqs-alerts.yaml

# 6. Deploy
./deploy.sh dev

# 7. Check email and confirm subscription
# (You'll receive email from AWS SNS)

# 8. Test
aws sns publish --topic-arn <your-topic-arn> \
  --subject "Test" --message "Test message"
```

---

## 📊 Alarms Summary

### Service Count
- **ALB**: 3 alarms
- **DynamoDB**: 4 alarms
- **ECS**: 6 alarms
- **SQS**: 5 alarms
- **Total**: 18 alarms

### Alert Frequency
- **Evaluation Period**: 60-300 seconds
- **Notification**: Immediate (within 1-5 minutes)
- **Email**: Via SNS subscription

---

## 🔧 Configuration Reference

### Default Thresholds
```yaml
ALB:
  5XX Errors: ≥ 10 (per minute)
  
DynamoDB:
  System Errors: ≥ 100 (per minute)
  Capacity Utilization: ≥ 80%
  
ECS:
  Errors: ≥ 5 (per minute)
  CPU: ≥ 85%
  Memory: ≥ 85%
  
SQS:
  DLQ Messages: ≥ 50
  Queue Depth: ≥ 1000
  Message Age: ≥ 3600 seconds
```

### Customization
- Edit `infra/config/dev/*.yaml` to change thresholds
- Use `sceptre update` to deploy changes
- Monitor for 24-48 hours after changes

---

## 📚 Documentation Map

| Document | Purpose |
|----------|---------|
| [README.md](README.md) | Complete technical documentation |
| [QUICKREF.md](QUICKREF.md) | Command reference and common tasks |
| [CONFIG_EXAMPLES.md](CONFIG_EXAMPLES.md) | Configuration examples and patterns |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Getting started guide |
| [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md) | This checklist |

---

## 🆘 Troubleshooting Quick Guide

### Installation Issues
```bash
# Update pip
pip install --upgrade pip

# Install with verbose output
pip install -v sceptre

# Check versions
python --version
sceptre --version
aws --version
```

### Deployment Issues
```bash
# Validate configuration
cd infra
sceptre validate dev

# Check AWS credentials
aws sts get-caller-identity

# Verbose deployment
sceptre launch -v dev
```

### Email Issues
```bash
# List subscriptions
aws sns list-subscriptions

# Check subscription details
aws sns list-subscriptions-by-topic \
  --topic-arn <your-topic-arn>

# Resend subscription confirmation
aws sns set-subscription-attributes \
  --subscription-arn <subscription-arn> \
  --attribute-name "Endpoint" \
  --attribute-value "your-email@example.com"
```

---

## 💡 Best Practices

### ✅ Do's
- Use separate configurations per environment
- Test alerts with synthetic data before production
- Monitor alarm activity for first 48 hours
- Document all threshold changes
- Use version control for configurations
- Review and update thresholds quarterly

### ❌ Don'ts
- Don't use same thresholds for dev/prod
- Don't ignore alarm noise (tune thresholds)
- Don't delete SNS topic without backing up subscriptions
- Don't skip email confirmation step
- Don't deploy to production without testing
- Don't leave default thresholds unchanged

---

## 🔐 Security Checklist

- [ ] AWS credentials are protected
- [ ] IAM policies follow least privilege
- [ ] Email recipients are authorized
- [ ] SNS topic has proper access controls
- [ ] CloudFormation templates are reviewed
- [ ] Sensitive data is not in version control
- [ ] Audit logging is enabled

---

## 📞 Support & Resources

### AWS Documentation
- [CloudWatch](https://docs.aws.amazon.com/cloudwatch/)
- [SNS](https://docs.aws.amazon.com/sns/)
- [CloudFormation](https://docs.aws.amazon.com/cloudformation/)

### Tools Documentation
- [Sceptre](https://sceptre.cloudreach.com/)
- [AWS CLI](https://docs.aws.amazon.com/cli/)

### Getting Help
1. Check logs: `sceptre launch -v dev`
2. Validate templates: `sceptre validate dev`
3. Review CloudFormation events
4. Check AWS CloudWatch console

---

## ✨ Next Steps After Deployment

1. **Monitor for 24-48 hours**
   - Watch for alarm triggers
   - Note false positives
   - Adjust thresholds as needed

2. **Create Runbooks**
   - Document incident response procedures
   - List escalation contacts
   - Define remediation steps

3. **Scale to Other Environments**
   - Create staging configuration
   - Create production configuration
   - Deploy with appropriate thresholds

4. **Integrate with Other Tools**
   - PagerDuty integration via SNS
   - Slack notifications via SNS Lambda
   - JIRA integration for ticket creation

5. **Regular Maintenance**
   - Review alarm effectiveness
   - Update thresholds quarterly
   - Archive old logs and metrics
   - Test disaster recovery

---

## 📈 Success Metrics

✅ **After 24 hours:**
- All stacks deployed successfully
- Email subscriptions confirmed
- Test notifications received

✅ **After 1 week:**
- 0 false positive alerts
- Team understands alert system
- Thresholds fine-tuned

✅ **After 1 month:**
- Team responding to alerts
- Incident response working smoothly
- Thresholds optimized for business

---

**Ready to get started?** Run: `./deploy.sh dev`

---

*Last Updated: January 22, 2025*  
*Infrastructure as Code Version: 1.0*  
*Sceptre Version: 2.7+*
