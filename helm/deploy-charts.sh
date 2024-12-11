#!/bin/bash

set -e

# Function to check and install yq
install_yq() {
  if ! command -v yq &>/dev/null; then
    echo "yq not found. Installing..."
    sudo wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
    sudo chmod +x /usr/local/bin/yq
    echo "yq installed successfully."
  fi
}

# Function to deploy a single Helm chart
deploy_chart() {
  local chart_dir="$1"
  local config_file="$chart_dir/config.yaml"

  echo "Deploying chart from directory: $chart_dir"

  # Parse config.yaml
  local repo_url
  repo_url=$(yq '.repo_url' "$config_file")
  local chart_name
  chart_name=$(yq '.chart_name' "$config_file")
  local namespace
  namespace=$(yq '.namespace' "$config_file")
  local version
  version=$(yq '.version // ""' "$config_file")

  echo "Parsed config: repo_url=$repo_url, chart_name=$chart_name, namespace=$namespace, version=$version"

  # Check if repo is already added, if not, add it
  local repo_name
  repo_name=$(basename "$repo_url" | tr -d ':/._-')
  if ! helm repo list | grep -q "$repo_name"; then
    echo "Adding Helm repo: $repo_url"
    helm repo add "$repo_name" "$repo_url"
    helm repo update
  fi

  # Fetch the chart into a temporary directory
  tmp_chart_dir=$(mktemp -d)
  echo "Fetching chart to temporary directory: $tmp_chart_dir"
  helm pull "$repo_name/$chart_name" --version "$version" --untar --untardir "$tmp_chart_dir"

  # Prepare customizations
  local custom_templates_dir="$chart_dir/templates"
  local custom_values_file="$chart_dir/values.yaml"
  local base_chart_dir="$tmp_chart_dir/$chart_name"

  # Merge templates
  if [[ -d "$custom_templates_dir" ]]; then
    echo "Checking custom templates in $custom_templates_dir"
    for template_file in "$custom_templates_dir"/*; do
      local filename
      filename=$(basename "$template_file")
      if [[ -f "$base_chart_dir/templates/$filename" ]]; then
        echo "Replacing template: $filename"
        cp "$template_file" "$base_chart_dir/templates/$filename"
      else
        echo "Adding new template: $filename"
        cp "$template_file" "$base_chart_dir/templates/"
      fi
    done
  fi

  # Prepare custom values
  local values_args=()
  if [[ -f "$custom_values_file" ]]; then
    values_args+=("-f" "$custom_values_file")
    echo "Using custom values from $custom_values_file"
  fi

  # Deploy the Helm chart
  echo "Deploying Helm chart: $chart_name to namespace: $namespace"
  helm upgrade --install "$chart_name" "$base_chart_dir" \
    --namespace "$namespace" --create-namespace "${values_args[@]}"

  # Cleanup
  rm -rf "$tmp_chart_dir"
  echo "Deployment complete for $chart_name"
}

# Main execution
main() {
  local helm_dir="helm"

  # Ensure yq is available
  install_yq

  echo "Processing Helm directory: $helm_dir"
  for chart_dir in "$helm_dir"/*; do
    if [[ -d "$chart_dir" && -f "$chart_dir/config.yaml" ]]; then
      echo "Found config.yaml in $chart_dir"

      # Check if the chart is enabled
      local enabled
      enabled=$(yq '.enable' "$chart_dir/config.yaml")
      echo "Enable flag for $chart_dir: $enabled"

      if [[ "$enabled" == "true" ]]; then
        echo "Chart is enabled. Deploying $chart_dir..."
        deploy_chart "$chart_dir"
      else
        echo "Chart is disabled. Skipping $chart_dir."
      fi
    fi
  done
}

# Run the script
main
