#!/bin/bash

# Define the charts and repositories
declare -A CHARTS
CHARTS["aws-ebs"]="https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
CHARTS["nginx-ingress"]="https://kubernetes.github.io/ingress-nginx"

# Fetch or update each chart
for chart in "${!CHARTS[@]}"; do
    echo "Updating chart: $chart"
    helm repo add $chart ${CHARTS[$chart]}
    helm pull $chart --untar -d ../helm/charts/
done

echo "All charts updated successfully!"
