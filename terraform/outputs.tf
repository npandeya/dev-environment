output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "control_nodes_private_ips" {
  value = aws_instance.control_nodes[*].private_ip
}

output "worker_nodes_private_ips" {
  value = aws_instance.worker_nodes[*].private_ip
}
