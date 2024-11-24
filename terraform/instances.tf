resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.bastion_instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name

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

  security_groups = [aws_security_group.nodes.id]

  tags = {
    Name = "Control Node ${count.index + 1}"
  }
}

resource "aws_instance" "worker_nodes" {
  count         = 3
  ami           = var.ami_id
  instance_type = var.worker_instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name

  security_groups = [aws_security_group.nodes.id]

  tags = {
    Name = "Worker Node ${count.index + 1}"
  }
}
