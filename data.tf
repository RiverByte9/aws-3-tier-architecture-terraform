data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {

    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]


  }
  owners = ["amazon"]

}

data "aws_region" "current" {

}