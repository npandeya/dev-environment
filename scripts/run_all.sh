#!/bin/bash

# Variables
INVENTORY_TEMPLATE="ansible/templates/inventory.j2"
LOCAL_INVENTORY_FILE="ansible/inventory.ini"
ANSIBLE_PLAYBOOK_DIR="ansible/playbooks"
TERRAFORM_DIR="terraform"
PEM_FILE="$HOME/.ssh/dev-env.pem"
ANSIBLE_DIR="ansible"
LOG_FILE="run_all.log"
LOG_DIR="logs"

# Start logging
exec > >(tee -a "$LOG_FILE") 2>&1

# Begin script
echo "===== Starting the Deployment Script ====="

echo "Log file: $LOG_FILE"
echo "Timestamp: $(date)"

# Initialize and apply Terraform configuration
echo "Initializing Terraform..."
cd "$TERRAFORM_DIR"
terraform init

if [[ $? -ne 0 ]]; then
  echo "Terraform initialization failed. Check the log file for details."
  exit 1
fi

echo "Applying Terraform configuration..."
terraform apply -auto-approve

if [[ $? -ne 0 ]]; then
  echo "Terraform apply failed. Check the log file for details."
  exit 1
fi

# Save Terraform outputs as JSON
echo "Fetching Terraform outputs..."
terraform output -json > ../state/terraform.tfstate.json

if [[ $? -ne 0 ]]; then
  echo "Failed to fetch Terraform outputs. Check the log file for details."
  exit 1
fi

# Render inventory locally
echo "Rendering inventory file using Ansible..."
cd ..
BASTION_HOST="ubuntu@$(terraform -chdir=$TERRAFORM_DIR output -raw bastion_public_ip)"
ansible-playbook -i localhost, $ANSIBLE_PLAYBOOK_DIR/render_inventory.yaml --extra-vars "@state/terraform.tfstate.json"

if [[ $? -ne 0 ]]; then
  echo "Failed to render inventory file. Check the log file for details."
  exit 1
fi

echo "Inventory file generated at $LOCAL_INVENTORY_FILE"
sleep 10

echo "Copying pem bastion host..."
scp -i "$PEM_FILE" -r "$PEM_FILE" "$BASTION_HOST:~/.ssh/dev-env.pem"

echo "Copying ansible dir to bastion host..."
scp -i "$PEM_FILE" -r "$ANSIBLE_DIR" "$BASTION_HOST:$REMOTE_ANSIBLE_DIR"

echo "Copying helm dir to bastion host..."
scp -i "$PEM_FILE" -r helm "$BASTION_HOST:helm"

if [[ $? -ne 0 ]]; then
  echo "Failed to copy inventory file to bastion host. Check the log file for details."
  exit 1
fi

# SSH into bastion and run playbooks
echo "Running Ansible playbooks from bastion host..."
sleep 10
ssh -i "$PEM_FILE" "$BASTION_HOST" << EOF
  echo "Step 1: Installing MicroK8s on all nodes..."
  ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_microk8s.yaml
  if [[ $? -ne 0 ]]; then
    echo "Failed to run setup_microk8s.yaml. Exiting."
    exit 1
  fi

  echo "Step 2: Configuring control and worker nodes..."
  ansible-playbook -i ansible/inventory.ini ansible/playbooks/configure_nodes.yaml
  if [[ $? -ne 0 ]]; then
    echo "Failed to run configure_nodes.yaml. Exiting."
    exit 1
  fi

  echo "Step 3: Setting up bastion host..."
  ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup_bastion.yaml
  if [[ $? -ne 0 ]]; then
    echo "Failed to run setup_bastion.yaml. Exiting."
    exit 1
  fi

  echo "Step 4: Deploying Helm charts..."
  ansible-playbook -i ansible/inventory.ini ansible/playbooks/deploy_helm_charts.yaml
  if [[ $? -ne 0 ]]; then
    echo "Failed to run deploy_helm_charts.yaml. Exiting."
    exit 1
  fi
EOF

echo "All playbooks executed successfully from bastion. Environment is set up!"

mkdir -p $LOG_DIR
mv $LOG_FILE $LOG_DIR/
echo "Log file saved at: $LOG_DIR/$LOG_FILE"
