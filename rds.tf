
// Generate a random password for the RDS instance
resource "random_password" "rds_password" {
  length  = 16
  special = false
}

// Store the RDS password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_password" {
  name = "${var.prefix}-rds-password"
}

resource "aws_secretsmanager_secret_version" "rds_password" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = jsonencode({ password = random_password.rds_password.result })
}

// Create a security group for the RDS instance
resource "aws_security_group" "rds" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-rds-sg" })
  )
}

// Create the RDS PostgreSQL instance
resource "aws_db_instance" "postgres" {
  identifier              = "${var.db_name}-postgres"
  engine                 = "postgres"
  engine_version         = "14.10"
  instance_class          = "db.t3.micro"
  allocated_storage       = 30
  username                = var.db_username
  password                = random_password.rds_password.result
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.main.name
  skip_final_snapshot     = true

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-postgres" })
  )
}

// Create a DB subnet group for the RDS instance
# resource "aws_db_subnet_group" "main" {
#   name       = "${var.prefix}-db-subnet-group"
#   subnet_ids = [aws_subnet.private.id]

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${local.prefix}-db-subnet-group" })
#   )
# }
# Create public subnet
# resource "aws_subnet" "public" {
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.subnet_cidr_list[0]
#   availability_zone = "${var.region}a"
#   map_public_ip_on_launch = true

#   tags = merge(
#     local.common_tags,
#     tomap({ "Name" = "${var.prefix}-public-subnet" })
#   )
# }

# Create private subnet in AZ a
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_a
  availability_zone = "${var.region}a"
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-private-subnet-a" })
  )
}

# Create private subnet in AZ b
resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr_b
  availability_zone = "${var.region}b"
  
  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-private-subnet-b" })
  )
}

# Update the DB subnet group to include both private subnets
# Create a DB subnet group for the RDS instance
resource "aws_db_subnet_group" "main" {
  name       = "${var.prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${var.prefix}-db-subnet-group" })
  )
}

// Create a security group for the EC2 instance
resource "aws_security_group" "ec2" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.rds.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-ec2-sg" })
  )
}

