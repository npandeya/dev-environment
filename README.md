# dev-environment
Full Dev Environment on K8s

# Dev Environment on AWS

This project automates the creation of a Kubernetes cluster on AWS using Terraform and Ansible. It includes:
- A bastion host for secure access.
- Kubernetes cluster with MicroK8s (3 control nodes and 3 worker nodes).
- Helm chart support.
- Graceful management of EC2 instances to reduce costs.
- Remote state management for Terraform.

## Terraform State Management

This project uses a **local backend** to store Terraform state files. The state file is stored in the `state/` directory and is ignored by version control.

### Best Practices
1. **Keep the State Secure**:
   - Restrict access to the state file using:
     ```bash
     chmod 600 state/terraform.tfstate
     ```
2. **Back Up Regularly**:
   - Create a backup of the state file periodically:
     ```bash
     cp state/terraform.tfstate state/terraform.tfstate.backup
     ```

### Migrate to Remote State
To migrate to a remote state (S3 + DynamoDB), update `backend.tf` as follows:
```hcl
terraform {
  backend "s3" {
    bucket         = "your-s3-bucket-name"
    key            = "dev-environment/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
```

### **Benefits of This Setup**

1. **Development-Friendly**:
   - No additional configuration or cloud services required for state storage.
2. **Security**:
   - The `.gitignore` ensures the state file doesn’t get committed to version control.
3. **Scalability**:
   - Easily switch to a remote backend when transitioning to production.

