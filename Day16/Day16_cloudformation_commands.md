# Day 16 ECS Fargate CloudFormation Lab Commands

## 1. Prerequisites

You need:

- AWS CLI configured
- Docker image already pushed to Amazon ECR
- IAM permissions for CloudFormation, ECS, EC2, ELB, IAM, and CloudWatch

Verify AWS login:

```bash
aws sts get-caller-identity
```

Example ECR image URI:

```text
123456789012.dkr.ecr.eu-north-1.amazonaws.com/hello-ecr:v2
```

---

## 2. Deploy the Stack

Replace the image URI and region as required.

```bash
aws cloudformation deploy \
  --template-file Day16_ecs_fargate_lab.yml \
  --stack-name day16-ecs-fargate-lab \
  --capabilities CAPABILITY_NAMED_IAM \
  --region eu-north-1 \
  --parameter-overrides \
    ProjectName=day16-ecs-fargate \
    ContainerImage=123456789012.dkr.ecr.eu-north-1.amazonaws.com/hello-ecr:v2 \
    ContainerPort=8080 \
    DesiredCount=1
```

---

## 3. Get the Application URL

```bash
aws cloudformation describe-stacks \
  --stack-name day16-ecs-fargate-lab \
  --region eu-north-1 \
  --query "Stacks[0].Outputs"
```

Open the `ApplicationURL` value in a browser.

---

## 4. Verify ECS Service

```bash
aws ecs list-clusters --region eu-north-1
```

```bash
aws ecs list-services \
  --cluster day16-ecs-fargate-cluster \
  --region eu-north-1
```

```bash
aws ecs list-tasks \
  --cluster day16-ecs-fargate-cluster \
  --service-name day16-ecs-fargate-service \
  --region eu-north-1
```

---

## 5. View Logs

```bash
aws logs describe-log-streams \
  --log-group-name /ecs/day16-ecs-fargate \
  --region eu-north-1
```

---

## 6. Scale the Service

```bash
aws ecs update-service \
  --cluster day16-ecs-fargate-cluster \
  --service day16-ecs-fargate-service \
  --desired-count 2 \
  --region eu-north-1
```

---

## 7. Cleanup

```bash
aws cloudformation delete-stack \
  --stack-name day16-ecs-fargate-lab \
  --region eu-north-1
```

Check deletion:

```bash
aws cloudformation describe-stacks \
  --stack-name day16-ecs-fargate-lab \
  --region eu-north-1
```
