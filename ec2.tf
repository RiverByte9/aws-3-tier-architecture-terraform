# Private EC2 instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_a.id # Updated reference
  availability_zone      = "${data.aws_region.current.name}a"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = "ssh-key"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-private-ec2" })
  )
}


# Public ec2
resource "aws_instance" "public" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public_subnet.id # Updated reference
  availability_zone      = "${data.aws_region.current.name}a"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = "ssh-key"

  tags = merge(
    local.common_tags,
    tomap({ "Name" = "${local.prefix}-public-ec2" })
  )
}
