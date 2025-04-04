# output.tf
output "ec2_public_ip" {
  description = "public ip for ec2"
  value       = aws_instance.public.public_ip
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}


output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.postgres.endpoint
}


output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}

output "ec2_instance_id" {
  description = "The ID of the private EC2 instance"
  value       = aws_instance.private.id
}
