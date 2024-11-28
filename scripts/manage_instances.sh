#!/bin/bash

# AWS Region
REGION="us-east-1"

# Function to stop all running instances
stop_instances() {
    echo "Stopping all running EC2 instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=Bastion Host,Control Node*,Worker Node*" \
                  "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].InstanceId" --output text --region $REGION)
    
    if [ -z "$INSTANCE_IDS" ]; then
        echo "No running instances found to stop."
        exit 0
    fi

    echo "Instances to be stopped: $INSTANCE_IDS"
    aws ec2 stop-instances --instance-ids $INSTANCE_IDS --region $REGION
    echo "Instances stopped: $INSTANCE_IDS"
}

# Function to start all stopped instances
start_instances() {
    echo "Starting all stopped EC2 instances..."
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=Bastion Host,Control Node*,Worker Node*" \
                  "Name=instance-state-name,Values=stopped" \
        --query "Reservations[*].Instances[*].InstanceId" --output text --region $REGION)
    
    if [ -z "$INSTANCE_IDS" ]; then
        echo "No stopped instances found to start."
        exit 0
    fi

    echo "Instances to be started: $INSTANCE_IDS"
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