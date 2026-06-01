## Command to create cloudformation

    aws cloudformation create-stack \
    --stack-name ramesh-ec2-stack \
    --template-body file://ramesh-ec2-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

## Delete cloudformation command

    aws cloudformation delete-stack \
    --stack-name ramesh-ec2-stack \
    --profile devops



## Command to create cloudformation for EC2 Web Server

    aws cloudformation create-stack \
    --stack-name ramesh-ec2-web-stack \
    --template-body file://ec2-web-server-template.yaml \
    --parameters \
      ParameterKey=KeyName,ParameterValue=ramesh-KeyPair \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

    Delete

    aws cloudformation delete-stack \
    --stack-name ramesh-ec2-web-stack \
    --profile devops


## Command to create cloudformation for S3 Bucket

    aws cloudformation create-stack \
    --stack-name ramesh-s3-stack \
    --template-body file://ramesh-s3-template.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --profile devops

    Delete

    aws cloudformation delete-stack \
    --stack-name ramesh-s3-stack \
    --profile devops