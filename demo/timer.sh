#!/bin/bash

# Default timer duration in seconds (can be customized)
TIMER=${1:-120} # Set to 2 minutes (120 seconds) if no argument is provided

# Colors
RED='\033[1;31m'
NC='\033[0m' # No Color

# Function to check and install figlet
install_figlet() {
    if ! command -v figlet &> /dev/null; then
        echo "Figlet is not installed. Attempting to install..."
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            if command -v brew &> /dev/null; then
                brew install figlet
            else
                echo "Homebrew is not installed. Please install Homebrew first (https://brew.sh/) and run the script again."
                exit 1
            fi
        elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
            # Linux
            if command -v apt-get &> /dev/null; then
                sudo apt-get install -y figlet
            elif command -v yum &> /dev/null; then
                sudo yum install -y figlet
            else
                echo "Unsupported Linux distribution. Please install figlet manually."
                exit 1
            fi
        else
            echo "Unsupported OS. Please install figlet manually."
            exit 1
        fi
    fi
}

# Function to display the timer with large ASCII art numbers in red
print_timer() {
    local time="$1"
    clear
    echo "###############################"
    echo "#                             #"
    echo -e "#   ${RED}We will be back in...${NC}     #"
    echo "#                             #"
    echo -e "${RED}"
    figlet "$time" # Display the time in large ASCII art with red color
    echo -e "${NC}"
    echo "#                             #"
    echo "#                             #"
    echo "#                             #"
    echo "###############################"
}

# Ensure figlet is installed
install_figlet

while [ $TIMER -gt 0 ]; do
    MINUTES=$((TIMER / 60))
    SECONDS=$((TIMER % 60))
    TIME=$(printf "%02d:%02d" $MINUTES $SECONDS)
    print_timer "$TIME"
    sleep 1
    ((TIMER--))
done

# Final message when time's up
clear
echo "###############################"
echo "#                             #"
echo "#         Time's Up!          #"
echo "#                             #"
echo "###############################"
