variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Name of the SSH key pair"
}

variable "ami_id" {
  description = "Ubuntu AMI for EC2 instances"
}

variable "bastion_instance_type" {
  default = "t2.micro"
}

variable "control_instance_type" {
  default = "t2.micro"
}

variable "worker_instance_type" {
  default = "t2.micro"
}
