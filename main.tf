terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = var.vpc_name }
}

resource "aws_subnet" "pubsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.pubsub_cidr
  tags = { Name = var.pubsub_name }
}

resource "aws_subnet" "pvtsub" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.pvtsub_cidr
  tags = { Name = var.pvtsub_name }
}

  
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
  tags = { Name = var.igw_name }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = var.pub_rt_name }
}

resource "aws_route_table_association" "pubrtassociation" {
  subnet_id      = aws_subnet.pubsub.id
  route_table_id = aws_route_table.pub-rt.id
}

resource "aws_eip" "eip" {
  domain   = "vpc"
}

resource "aws_nat_gateway" "mynat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pubsub.id
  tags = { Name = var.nat_name }
}

resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mynat.id
  }
  tags = { Name = var.pvt_rt_name }
}

resource "aws_route_table_association" "pvtrtassociation" {
  subnet_id      = aws_subnet.pvtsub.id
  route_table_id = aws_route_table.pvt-rt.id
}

resource "aws_security_group" "pub-sg" {
  name        = var.pub_sg_name
  description = "This is public security group"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = var.pub_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "pub_sg_http" {
  security_group_id = aws_security_group.pub-sg.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_ingress_rule" "pub_sg_ssh" {
  security_group_id = aws_security_group.pub-sg.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp" 
  to_port     = 22
}

resource "aws_vpc_security_group_egress_rule" "pubegress" {
  security_group_id = aws_security_group.pub-sg.id  
  from_port   = 0
  to_port     = 0
  ip_protocol    = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_security_group" "pvt-sg" {
  name        = var.pvt_sg_name
  description = "This is private security group"
  vpc_id      = aws_vpc.myvpc.id
  tags = {
    Name = var.pvt_sg_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "pvt_sg_http" {
  security_group_id = aws_security_group.pvt-sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  referenced_security_group_id = aws_security_group.pub-sg.id
}

resource "aws_vpc_security_group_ingress_rule" "pvt_sg_ssh" {
  security_group_id = aws_security_group.pvt-sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  referenced_security_group_id = aws_security_group.pub-sg.id
}


resource "aws_vpc_security_group_egress_rule" "pvtegress" {
  security_group_id = aws_security_group.pvt-sg.id  
  from_port   = 0
  to_port     = 0
  ip_protocol    = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
resource "aws_instance" "public-instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pubsub.id
  security_groups        = [aws_security_group.pub-sg.id]
  associate_public_ip_address = true
  key_name               = "public-instance-keypair"  

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    echo "This is public instance" > /var/www/html/index.html
    systemctl restart apache2
  EOF

  tags = { Name = var.public_instance_name }
}

resource "aws_instance" "private-instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pvtsub.id
  security_groups        = [aws_security_group.pvt-sg.id]
  associate_public_ip_address = false
  key_name               = "private-instance-keypair"  

  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    echo "This is private instance" > /var/www/html/index.html
    systemctl restart apache2
  EOF

  tags = { Name = var.private_instance_name }
}
