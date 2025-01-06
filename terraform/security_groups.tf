data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

resource "aws_security_group" "bastion" {
  name        = "bastion-sg"
  description = "Security group for the bastion host"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_security_group" "nodes" {
  name        = "nodes-sg"
  description = "Security group for control and worker nodes"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "nodes-sg"
  }
}

# Allow SSH from the Internet to the bastion
resource "aws_security_group_rule" "bastion_ssh_ingress" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  cidr_blocks              = ["${trimspace(data.http.my_ip.response_body)}/32"]
  security_group_id        = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_openvpn_ingress" {
  type                     = "ingress"
  from_port                = 1194
  to_port                  = 1194
  protocol                 = "udp"
  cidr_blocks              = ["${trimspace(data.http.my_ip.response_body)}/32"]
  security_group_id        = aws_security_group.bastion.id
}

# Allow all traffic to/from nodes
resource "aws_security_group_rule" "bastion_to_nodes_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_to_nodes_egress" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.bastion.id
}

# Allow outbound Internet access from the bastion
resource "aws_security_group_rule" "bastion_internet_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# Allow inbound anywhere from node 
resource "aws_security_group_rule" "node_inbound_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [aws_vpc.main.cidr_block]
  security_group_id = aws_security_group.nodes.id
}

# Allow all traffic between nodes
resource "aws_security_group_rule" "nodes_self_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

resource "aws_security_group_rule" "nodes_self_ingress_udp" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.nodes.id
}

# Allow traffic from the bastion
resource "aws_security_group_rule" "nodes_from_bastion_ingress" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.nodes.id
}

# Allow outbound Internet access from the nodes
resource "aws_security_group_rule" "nodes_internet_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}