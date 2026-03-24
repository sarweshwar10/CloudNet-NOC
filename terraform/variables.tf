variable "aws_region" {
  default = "us-east-1"
}

variable "project" {
  default = "CloudNet"
}

variable "account_id" {
  default = "YOUR_ACCOUNT_ID"
}

variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  default = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnets" {
  default = ["10.10.10.0/24", "10.10.20.0/24"]
}

variable "db_subnets" {
  default = ["10.10.100.0/24", "10.10.200.0/24"]
}

variable "azs" {
  default = ["us-east-1a", "us-east-1b"]
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {
  default = "cloudnetdb"
}

variable "db_username" {
  default = "admin"
}