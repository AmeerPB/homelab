variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "my_ip" {
  description = "Your IP address with /32 mask"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID to use"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "instance_name" {
  description = "EC2 instance name tag"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to launch resources in"
  type = string
}

variable "subnet_id" {
  description = "Subnet ID to launch the EC2 instance in"
  type = string
}