resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  root_block_device {
    volume_type = "gp3"  # General Purpose SSD
    volume_size = 10     # Size in GB
    delete_on_termination = true
  }

  security_groups = [aws_security_group.bastion.id]

  tags = {
    Name = "Bastion Host"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y ansible
              EOF
}

resource "aws_instance" "control_nodes" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.control_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  root_block_device {
    volume_type = "gp3"  # General Purpose SSD
    volume_size = 10     # Size in GB
    delete_on_termination = true
  }

  security_groups = [aws_security_group.nodes.id]

  tags = {
    Name = "Control Node ${count.index + 1}"
    "kubernetes.io/cluster/dev"   = "owned"
    "kubernetes.io/role/internal-elb"    = "1"
  }
}

resource "aws_instance" "worker_nodes" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  root_block_device {
    volume_type = "gp3"  # General Purpose SSD
    volume_size = 20     # Size in GB
    delete_on_termination = true
  }

  security_groups = [aws_security_group.nodes.id]

  tags = {
    Name = "Worker Node ${count.index + 1}"
    "kubernetes.io/cluster/dev"   = "owned"
    "kubernetes.io/role/internal-elb"    = "1"
  }
}
