#!/bin/bash

# AWS Region
REGION="us-east-1"

# Function to stop all instances
stop_instances() {
    echo "Stopping all EC2 instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=Bastion Host,Control Node*,Worker Node*" \
        --query "Reservations[*].Instances[*].InstanceId" --output text --region $REGION)
    
    if [ -z "$INSTANCE_IDS" ]; then
        echo "No instances found to stop."
        exit 0
    fi

    aws ec2 stop-instances --instance-ids $INSTANCE_IDS --region $REGION
    echo "Instances stopped: $INSTANCE_IDS"
}

# Function to start all instances
start_instances() {
    echo "Starting all EC2 instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=Bastion Host,Control Node*,Worker Node*" \
        --query "Reservations[*].Instances[*].InstanceId" --output text --region $REGION)
    
    if [ -z "$INSTANCE_IDS" ]; then
        echo "No instances found to start."
        exit 0
    fi

    aws ec2 start-instances --instance-ids $INSTANCE_IDS --region $REGION
    echo "Instances started: $INSTANCE_IDS"
}

# Main script
case $1 in
    start)
        start_instances
        ;;
    stop)
        stop_instances
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
