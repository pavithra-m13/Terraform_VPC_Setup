variable "aws_region" {
  default = "us-east-2"
}

variable "vpc_cidr" {
  default = "50.30.0.0/16"
}

variable "pubsub_cidr" {
  default = "50.30.10.0/24"
}

variable "pvtsub_cidr" {
  default = "50.30.20.0/24"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0b40807e5dc1afecf"
}

variable "vpc_name" {
  default = "myvpc"
}

variable "pubsub_name" {
  default = "pubsub"
}

variable "pvtsub_name" {
  default = "pvtsub"
}

variable "igw_name" {
  default = "igw"
}

variable "eip_name" {
  default = "eip"
}

variable "nat_name" {
  default = "mynat"
}

variable "pub_rt_name" {
  default = "pub-rt"
}

variable "pvt_rt_name" {
  default = "pvt-rt"
}

variable "pub_sg_name" {
  default = "pub-sg"
}

variable "pvt_sg_name" {
  default = "pvt-sg"
}

variable "public_instance_name" {
  default = "public-instance"
}

variable "private_instance_name" {
  default = "private-instance"
}
