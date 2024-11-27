# Local Environment Setup

This guide explains how to set up your local environment to provision AWS infrastructure using Terraform and manage the deployment process. Most configuration and runtime dependencies (e.g., Ansible, Helm) will run on the bastion host, so your local setup remains minimal.

---

## **1. Prerequisites**

### 1.1 **Operating System**
- A Linux-based OS (Ubuntu recommended), macOS, or Windows with WSL.

### 1.2 **Required Tools**
Install the following tools on your local machine:

1. **Terraform**
   - [Download Terraform](https://developer.hashicorp.com/terraform/downloads)
   - Verify installation:
     ```bash
     terraform version
     ```

2. **Ansible**
   - [Download Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
   - Verify installation:
     ```bash
     ansible --version
     ```

3. **AWS CLI**
   - [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
   - Verify installation:
     ```bash
     aws --version
     ```

4. **jq**
   - Linux:
     ```bash
     sudo apt update && sudo apt install jq -y
     ```
   - macOS:
     ```bash
     brew install jq
     ```
   - Verify installation:
     ```bash
     jq --version
     ```

5. **SSH Key Management**
   - Ensure you have `ssh-keygen` available for managing SSH keys.

---

## **2. Configure AWS CLI**
> **Note:** Make sure AWS is setup before executing this step. 
Refer to the [aws-setup.md](./aws-setup.md) for detailed instructions on setting up AWS cloud.

Run the following command to set up your AWS credentials:
```bash
aws configure
```
You will be prompted to provide:
- **Access Key ID**: Your AWS access key.
- **Secret Access Key**: Your AWS secret access key.
- **Default Region**: Example: `us-east-1`.

### Verify AWS CLI Configuration
1. **List available regions**:
  ```bash
  aws ec2 describe-regions --output table
  ```

2. **Check your account ID**:
  ```bash
  aws sts get-caller-identity
  ```

3. **Ensure IAM permissions**:
  ```bash 
  aws iam list-account-aliases
  ```

## **3. Generate an SSH Key**
Terraform uses an SSH key pair to provision EC2 instances. Follow these steps to create a key pair:

1. **Generate an SSH key**:
  ```bash
  ssh-keygen -t rsa -b 2048 -f ~/.ssh/dev-env.pem
  ```

2. **Set permissions for the private key**:
  ```bash
  chmod 600 ~/.ssh/dev-env.pem
  ```
## **4. Clone the Repository**
Clone the project repository to your local machine:
```bash 
git clone git@github.com:npandeya/dev-environment.git
cd dev-environment 
```
## **5. Terraform State Management**

This project uses a **local backend** to store Terraform state files. By default:
- State files are stored in `../state/terraform.tfstate`.

### Verify Terraform Backend Configuration
Open `terraform/backend.tf` and confirm the backend configuration:
```hcl
terraform {
  backend "local" {
    path = "../state/terraform.tfstate"
  }
}
```
### Secure the State File

Restrict permissions to the state file:
```bash
chmod 600 ../state/terraform.tfstate
```

## **6. Install Terraform Modules**

Navigate to the `terraform/` directory and initialize Terraform modules:
```bash
cd terraform
terraform init
```

## **7. Verify Local Setup**

Once all tools are installed and configured, verify your environment:

1. **Terraform**:
  ```bash
  terraform version
  ```

2. **AWS CLI**:
  ```bash
  aws sts get-caller-identity
  ```

3. **jq**:
  ```bash
  jq --version
  ```
4. **SSH Key**: Ensure the SSH private key exists:
  ```bash
  ls -l ~/.ssh/dev-env.pem 
  ```

## **8. Next Steps**

After completing the local environment setup:
- Terraform will provision the required AWS infrastructure.
- Ansible and Helm will be configured and executed directly from the bastion host.

Refer to the [documentation directory](./) for detailed instructions on provisioning and deployment.






