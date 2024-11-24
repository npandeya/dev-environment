#!/bin/bash

# Paths
TERRAFORM_DIR="../terraform"
ANSIBLE_DIR="../ansible/templates"

# Step 1: Run Terraform
echo "Initializing and applying Terraform..."
cd $TERRAFORM_DIR
terraform init
terraform apply -auto-approve

# Step 2: Capture Terraform Outputs
echo "Capturing Terraform outputs..."
BASTION_IP=$(terraform output -raw bastion_public_ip)
CONTROL_IPS=$(terraform output -json control_nodes_private_ips | jq -r '.[]')
WORKER_IPS=$(terraform output -json worker_nodes_private_ips | jq -r '.[]')

# Step 3: Update Ansible Inventory
echo "Updating Ansible inventory..."
cat > $ANSIBLE_DIR/inventory.j2 <<EOL
[bastion]
bastion ansible_host=${BASTION_IP}

[control_nodes]
{% for ip in control_ips %}
control{{ loop.index }} ansible_host={{ ip }}
{% endfor %}

[worker_nodes]
{% for ip in worker_ips %}
worker{{ loop.index }} ansible_host={{ ip }}
{% endfor %}
EOL

# Step 4: Copy Ansible Files to Bastion
echo "Copying Ansible files to Bastion host..."
scp -i ~/.ssh/dev-env.pem -r ../ansible ubuntu@$BASTION_IP:~/ansible

# Step 5: Execute Ansible Playbooks from Bastion
echo "Running Ansible playbooks from Bastion..."
ssh -i ~/.ssh/dev-env.pem ubuntu@$BASTION_IP << 'EOF'
  cd ~/ansible
  ansible-playbook -i templates/inventory.j2 playbooks/setup_microk8s.yaml
  ansible-playbook -i templates/inventory.j2 playbooks/configure_nodes.yaml
  ansible-playbook -i templates/inventory.j2 playbooks/deploy_helm_charts.yaml
EOF

echo "Setup complete!"
