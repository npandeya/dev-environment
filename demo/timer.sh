#!/bin/bash

# Default timer duration in seconds (can be customized)
TIMER=${1:-120} # Set to 2 minutes (120 seconds) if no argument is provided

# Function to display the timer with ASCII art style
print_timer() {
    local time="$1"
    clear
    echo "###############################"
    echo "#                             #"
    echo "#     We will be back in...   #"
    echo "#                             #"
    echo "#          $time             #"
    echo "#                             #"
    echo "###############################"
}

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
