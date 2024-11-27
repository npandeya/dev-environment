#!/bin/bash

# Variables
IMAGE_NAME="dev-env"
DOCKERFILE="Dockerfile"
SSH_KEY="$HOME/.ssh/dev-env.pem"
AWS_CREDENTIALS="$HOME/.aws/credentials"
STATE_DIR="$(pwd)/state"
LOGS_DIR="$(pwd)/logs"
ENTRYPOINT=""
RUNTIMES=("docker" "podman" "nerdctl")

# Check for SSH key
if [[ ! -f "$SSH_KEY" ]]; then
  echo "Error: $SSH_KEY not found."
  echo "Please generate the private key following the documentation and upload the public key to the AWS EC2 console."
  exit 1
fi

# Check for AWS credentials
if [[ -f "$AWS_CREDENTIALS" ]]; then
  echo "AWS credentials found at $AWS_CREDENTIALS."
  read -p "Are these credentials correct? (yes/no): " AWS_VALIDATION
  if [[ "$AWS_VALIDATION" != "yes" ]]; then
    echo "Please update your credentials in $AWS_CREDENTIALS or set them via environment variables."
    exit 1
  fi
else
  echo "AWS credentials not found. Please provide the environment variables."
  read -p "AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
  read -p "AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
  read -p "AWS_DEFAULT_REGION (default: us-east-1): " AWS_DEFAULT_REGION
  AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:-us-east-1}
fi

# Prompt user for container runtime
echo "Select your container runtime:"
select RUNTIME in "${RUNTIMES[@]}"; do
  if [[ -n "$RUNTIME" ]]; then
    echo "Selected runtime: $RUNTIME"
    break
  else
    echo "Invalid selection. Try again."
  fi
done

# Ensure runtime is installed
if ! command -v "$RUNTIME" &>/dev/null; then
  echo "Error: $RUNTIME is not installed."
  exit 1
fi

# Prompt for deploy or destroy
echo "Choose an action:"
select ACTION in "deploy" "destroy"; do
  case $ACTION in
  deploy)
    ENTRYPOINT="run_all.sh"
    break
    ;;
  destroy)
    ENTRYPOINT="destroy_everything.sh"
    break
    ;;
  *)
    echo "Invalid selection. Try again."
    ;;
  esac
done

# Build the image with a unique name
UNIQUE_TAG="$IMAGE_NAME-${RUNTIME// /-}:latest"
echo "Building image $UNIQUE_TAG using $RUNTIME..."
$RUNTIME build -t "$UNIQUE_TAG" -f "$DOCKERFILE" .

if [[ $? -ne 0 ]]; then
  echo "Error: Failed to build the image."
  exit 1
fi

# Run the container
echo "Running container with entrypoint $ENTRYPOINT..."
if [[ -f "$AWS_CREDENTIALS" ]]; then
  $RUNTIME run --rm -it \
    --network host \
    -v ~/.ssh:/root/.ssh:ro \
    -v ~/.aws:/root/.aws:ro \
    -v "$STATE_DIR:/workspace/state" \
    -v "$LOGS_DIR:/workspace/logs" \
    "$UNIQUE_TAG" "/workspace/scripts/$ENTRYPOINT"
else
  $RUNTIME run --rm -it \
    --network host \
    -v ~/.ssh:/root/.ssh:ro \
    -v "$STATE_DIR:/workspace/state" \
    -v "$LOGS_DIR:/workspace/logs" \
    -e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
    -e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
    -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
    "$UNIQUE_TAG" "/workspace/scripts/$ENTRYPOINT"
fi
