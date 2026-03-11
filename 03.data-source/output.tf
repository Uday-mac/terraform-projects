output "vpc_name" {
  value = data.aws_vpc.vpc_name.id
}

output "subent_id" {
  value = data.aws_subnet.shared.id
}

output "ami_id" {
  value = data.aws_ami.ubuntu.name
}