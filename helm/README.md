# Helm Charts and Custom Values

This directory contains:
1. **Upstream Helm Charts**: Stored in `charts/`, these are the charts downloaded from official repositories.
2. **Custom Values**: Stored in `values/`, these files override the defaults in the charts.

## Workflow

### 1. Adding/Updating Upstream Helm Charts
Fetch the required Helm charts:
```bash
helm repo add aws-ebs https://kubernetes-sigs.github.io/aws-ebs-csi-driver
helm pull aws-ebs/aws-ebs-csi-driver --untar -d charts/