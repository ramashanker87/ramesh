output "s3_bucket_name" {
  description = "Created S3 bucket name"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "vpc_id" {
  description = "Created VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Created public subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Created security group ID"
  value       = aws_security_group.web_sg.id
}

output "ec2_instance_id" {
  description = "Created EC2 instance ID"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP address of EC2 instance"
  value       = aws_instance.web.public_ip
}

output "website_url" {
  description = "HTTP URL for web server"
  value       = "http://${aws_instance.web.public_ip}"
}