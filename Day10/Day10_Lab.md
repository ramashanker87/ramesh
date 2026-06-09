
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

Description: Create S3 Bucket

Parameters:
  EnvironmentName:
    Type: String
    Default: dev

Resources:
  RameshDemoBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${EnvironmentName}-demo-bucket-ramesh"

Outputs:
  BucketName:
    Value: !Ref RameshDemoBucket
```

---

# Step 3 — Validate Template

```bash
aws cloudformation validate-template --template-body file://s3-stack.yaml --profile devops
```

---

# Step 4 — Deploy Stack

```bash
aws cloudformation create-stack --stack-name s3-demo-stack-ramesh --template-body file://s3-stack.yaml --parameters ParameterKey=EnvironmentName,ParameterValue=dev --profile devops
```

---

# Step 5 — Verify Deployment

```bash
aws cloudformation describe-stacks --stack-name s3-demo-stack-ramesh --profile devops
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
  RameshDemoVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
```

---

# Step 2 — Create S3 Bucket

```bash
aws s3 mb s3://cf-template-storage-demo-ramesh --profile devops
```

---

# Step 3 — Upload Child Template

```bash
aws s3 cp network.yaml s3://cf-template-storage-demo-ramesh/ --profile devops
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
      TemplateURL: https://cf-template-storage-demo-ramesh.s3.amazonaws.com/network.yaml
```

---

# Step 5 — Deploy Parent Stack

```bash
aws cloudformation create-stack --stack-name parent-stack-ramesh --template-body file://parent-stack.yaml --profile devops
```

---

# Lab 3 — Multi-Environment Provisioning

## environment stack

```
AWSTemplateFormatVersion: '2010-09-09'

Description: Multi-environment CloudFormation template

Parameters:
  Environment:
    Type: String
    AllowedValues:
      - dev
      - test
      - prod
    Description: Deployment environment

Resources:
  EnvironmentBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub "${Environment}-demo-bucket-${AWS::AccountId}"
      Tags:
        - Key: Environment
          Value: !Ref Environment

        - Key: ManagedBy
          Value: CloudFormation

Outputs:
  BucketName:
    Description: Name of the created S3 bucket
    Value: !Ref EnvironmentBucket

  BucketArn:
    Description: ARN of the S3 bucket
    Value: !GetAtt EnvironmentBucket.Arn
```


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

## Creating Reusable EC2 Web Server Template for Dev, Test, and Prod

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Reusable EC2 Web Server Template for Dev, Test, and Prod

Parameters:

  Environment:
    Type: String
    Description: Environment Name
    AllowedValues:
      - dev
      - test
      - prod

  KeyPairName:
    Type: AWS::EC2::KeyPair::KeyName
    Description: Existing EC2 Key Pair

Resources:

  WebServerSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Allow HTTP and SSH Access
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 22
          ToPort: 22
          CidrIp: 0.0.0.0/0

        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0

      Tags:
        - Key: Name
          Value: !Sub "${Environment}-web-sg"

  WebServer:
    Type: AWS::EC2::Instance
    Properties:
      InstanceType: t2.micro

      KeyName: !Ref KeyPairName

      # Update AMI ID according to your region if needed
      ImageId: ami-0f58b397bc5c1f2e8

      SecurityGroups:
        - !Ref WebServerSecurityGroup

      Tags:
        - Key: Name
          Value: !Sub "rama-${Environment}-web-server"

      UserData:
        Fn::Base64: !Sub |
          #!/bin/bash
          yum update -y
          yum install -y httpd

          systemctl start httpd
          systemctl enable httpd

          cat > /var/www/html/index.html << EOF
          <html>
          <head><title>${Environment} Server</title></head>
          <body>
            <h1>Welcome to ${Environment} server</h1>
          </body>
          </html>
          EOF

Outputs:

  InstanceId:
    Description: EC2 Instance ID
    Value: !Ref WebServer

  PublicIP:
    Description: Public IP Address
    Value: !GetAtt WebServer.PublicIp

  URL:
    Description: Web Server URL
    Value: !Sub "http://${WebServer.PublicIp}"
```

## Deploy Dev Environment

```bash
aws cloudformation create-stack --stack-name rama-dev-stack --template-body file://environment-stack.yaml \
--parameters ParameterKey=Environment,ParameterValue=dev ParameterKey=KeyPairName=my-keypair --profile devops
```

---

## Deploy Test Environment

```bash
aws cloudformation create-stack --stack-name rama-test-stack --template-body file://environment-stack.yaml \
--parameters ParameterKey=Environment,ParameterValue=test ParameterKey=KeyPairName,my-keypair --profile devops
```

---

## Deploy Prod Environment

```bash
aws cloudformation create-stack --stack-name rama-prod-stack --template-body file://environment-stack.yaml \
--parameters ParameterKey=Environment,ParameterValue=prod ParameterKey=KeyPairName,ParameterValue=my-keypair --profile devops
```

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

## Assignment

    Create three EC2 multienvironment dev test prod
    example: rama-dev-web-server,rama-test-web-server,rama-prod-web-server
    Each of EC2 should have we server install and have index.html
    When access dev it should display
        Welcome to Dev server
    Similarly for test and prod
     Make sure its accessible through http IP address.

