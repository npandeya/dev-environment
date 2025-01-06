#!/bin/bash
PEM_FILE="$HOME/.ssh/dev-env.pem"
cd terraform
terraform init
# Define ANSI color codes
RED='\033[1;31m'    # Red color
NC='\033[0m'        # No Color (reset)
BOLD='\033[1m'      # Bold text

# Display the message in red, bold, and emphasize it with a border
echo -e "${RED}${BOLD}"
echo "###############################################"
echo "#                                             #"
echo "#      DESTROYING ALL RESOURCES...            #"
echo "#      CANCEL IF UNINTENDED                   #"
echo "#      WAITING FOR 30 SECONDS                 #"
echo "#                                             #"
echo "###############################################"
echo -e "${NC}"

# Counter loop
for ((i=1; i<=30; i++)); do
  printf "${RED}${BOLD}Waiting %02d seconds... Press Ctrl+C to cancel.${NC}\r" "$i"
  sleep 1
done
echo
BASTION_HOST="ubuntu@$(terraform output -raw bastion_public_ip)"
# SSH into bastion and run helm uninstall
echo "Running helm uninstall to uninstall all outside of terraform dependencies..."
sleep 10
echo "ssh -i "$PEM_FILE" "$BASTION_HOST""
ssh -i "$PEM_FILE" "$BASTION_HOST" << 'EOF'
  echo $HOSTNAME
  helm list --all-namespaces --short | grep -v 'aws-load-balancer-controller' | xargs -I{} sh -c 'helm uninstall {} --namespace $(helm list --all-namespaces | grep {} | awk "{print \$2}")'
EOF

echo "All helms destroyed now its turn for the aws resources!"
echo 
echo "Destroying all resources..."
for ((i=1; i<=10; i++)); do
  printf "${RED}${BOLD}Waiting %02d seconds... Press Ctrl+C to cancel.${NC}\r" "$i"
  sleep 1
done
terraform destroy --auto-approve 
