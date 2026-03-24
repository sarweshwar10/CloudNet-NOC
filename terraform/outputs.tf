output "vpc_id" {
  description = "HQ VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "db_subnet_ids" {
  description = "DB subnet IDs"
  value       = aws_subnet.db[*].id
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = aws_nat_gateway.main.id
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "app_sg_id" {
  description = "App Server Security Group ID"
  value       = aws_security_group.app.id
}

output "db_sg_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.db.id
}