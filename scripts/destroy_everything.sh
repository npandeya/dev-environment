cd terraform

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
terraform destroy
