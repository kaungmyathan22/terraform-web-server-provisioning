variable "ami_owner" {
  description = "Owner of the ami"
  type        = string
}

variable "ami_virtualization_type" {
  description = "Virtualization type of the ami"
  type        = string
}

variable "ami_name" {
  description = "Name of the ami"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "vpc_cidr_block" {
  type        = string
  description = "vpc cidr block"
}

variable "subnet_cidr_block" {
  type        = string
  description = "subnet cidr block"
}

variable "subnet_az" {
  type        = string
  description = "Availability zone for your subnet"
}


variable "instance_type" {
  type        = string
  description = "Type for ec2 instance"
}
