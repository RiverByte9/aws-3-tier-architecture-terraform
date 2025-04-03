variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "prefix" {
  default = "main"
}

variable "project" {
  default = "devops-tf"
}

variable "contact" {
  default = "kajalsks909@gmail.com"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnet_cidr_list" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "instance_type" {
  default = "t2.micro"
}

variable "db_name" {
  description = "The name of the RDS database"
  type        = string
  default     = "mydatabase"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
  default     = "admin"
}
variable "private_subnet_cidr_a" {
  description = "CIDR block for private subnet in AZ a"
  type        = string
  default     = "10.0.3.0/24"  # Changed from 10.0.1.0/24
}

variable "private_subnet_cidr_b" {
  description = "CIDR block for private subnet in AZ b"
  type        = string
  default     = "10.0.4.0/24"  # Changed from 10.0.2.0/24
}