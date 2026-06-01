
# Day 10 Lab Guide — Advanced CloudFormation
## Module 2 – Infrastructure as Code (IaC)
### Date: 29-May-2026 (Friday)

# 4-Hour Hands-on Lab

| Time | Lab |
|---|---|
| 09:00 – 10:00 | CloudFormation Stack Deployment |
| 10:00 – 11:00 | Nested Stacks Lab |
| 11:00 – 12:00 | StackSets Demonstration |
| 12:00 – 13:00 | Multi-Environment Provisioning |

---

# Lab Objectives

Participants will:
- Deploy CloudFormation templates
- Use AWS CLI commands
- Create Nested Stacks
- Understand StackSets
- Provision Dev/Test/Prod environments

---

# Prerequisites

- AWS Account
- AWS CLI Installed
- IAM Permissions
- CloudFormation access
- S3 access

---

# Lab 1 — Create CloudFormation Stack Using AWS CLI

## Step 1 — Create Working Directory

```bash
mkdir day10-lab
cd day10-lab
```

---

# Step 2 — Create CloudFormation Template

File:
```text
s3-stack.yaml
```

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: Create S3 Bucket

Parameters:
  EnvironmentName:
    Type: String
    Default: dev

Resources:
  DemoBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${EnvironmentName}-demo-bucket"

Outputs:
  BucketName:
    Value: !Ref DemoBucket
```

---

# Step 3 — Validate Template

```bash
aws cloudformation validate-template --template-body file://s3-stack.yaml --profile devops
```

---

# Step 4 — Deploy Stack

```bash
aws cloudformation create-stack --stack-name s3-demo-stack --template-body file://s3-stack.yaml --parameters ParameterKey=EnvironmentName,ParameterValue=dev --profile devops
```

---

# Step 5 — Verify Deployment

```bash
aws cloudformation describe-stacks --stack-name s3-demo-stack --profile devops
```

---

# Lab 2 — Nested Stacks

## Step 1 — Create Child Template

File:
```text
network.yaml
```

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Resources:
  DemoVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
```

---

# Step 2 — Create S3 Bucket

```bash
aws s3 mb s3://cf-template-storage-demo --profile devops
```

---

# Step 3 — Upload Child Template

```bash
aws s3 cp network.yaml s3://cf-template-storage-demo/ --profile devops
```

---

# Step 4 — Create Parent Template

File:
```text
parent-stack.yaml
```

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Resources:
  NetworkStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://cf-template-storage-demo.s3.amazonaws.com/network.yaml
```

---

# Step 5 — Deploy Parent Stack

```bash
aws cloudformation create-stack --stack-name parent-stack --template-body file://parent-stack.yaml --profile devops
```

---

# Lab 3 — Multi-Environment Provisioning

## Deploy Dev Environment

```bash
aws cloudformation create-stack --stack-name dev-stack --template-body file://environment-stack.yaml --parameters ParameterKey=Environment,ParameterValue=dev --profile devops
```

---

## Deploy Test Environment

```bash
aws cloudformation create-stack --stack-name test-stack --template-body file://environment-stack.yaml --parameters ParameterKey=Environment,ParameterValue=test --profile devops
```

---

## Deploy Prod Environment

```bash
aws cloudformation create-stack --stack-name prod-stack --template-body file://environment-stack.yaml --parameters ParameterKey=Environment,ParameterValue=prod --profile devops
```

---

# Lab 4 — StackSets Demonstration

## Create StackSet Template

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Resources:
  SharedBucket:
    Type: AWS::S3::Bucket
```

---

# StackSet Deployment Steps

1. Open CloudFormation Console
2. Navigate to StackSets
3. Create StackSet
4. Select regions
5. Deploy stack instances

---

# Cleanup Commands

```bash
aws cloudformation delete-stack --stack-name s3-demo-stack --profile devops
```

```bash
aws cloudformation delete-stack --stack-name parent-stack --profile devops
```

```bash
aws cloudformation delete-stack --stack-name dev-stack --profile devops
```

```bash
aws cloudformation delete-stack --stack-name test-stack --profile devops
```

```bash
aws cloudformation delete-stack --stack-name prod-stack --profile devops
```

---

# Troubleshooting Guide

| Issue | Solution |
|---|---|
| Template validation failed | Check YAML indentation |
| Stack creation failed | Review stack events |
| Access denied | Verify IAM permissions |
| Bucket already exists | Use unique names |

---

# Expected Outcomes

Participants will:
- Use AWS CLI with CloudFormation
- Create Nested Stacks
- Understand StackSets
- Provision multiple environments

