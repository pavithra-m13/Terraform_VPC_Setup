output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "public_subnet_id" {
  value = aws_subnet.pubsub.id
}

output "private_subnet_id" {
  value = aws_subnet.pvtsub.id
}

output "public_instance_id" {
  value = aws_instance.public-instance.id
}

output "private_instance_id" {
  value = aws_instance.private-instance.id
}
