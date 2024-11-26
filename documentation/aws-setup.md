# Setting Up AWS Cloud from Scratch

This guide walks you through setting up AWS Cloud from scratch, including signing up for the AWS free tier, generating access tokens, creating billing alarms, and managing EC2 private keys.

---

## **1. Sign Up for AWS Free Tier**

1. Visit the [AWS Free Tier Signup Page](https://aws.amazon.com/free).
2. Click **Create a Free Account**.
3. Follow the steps to:
   - Provide your email and create a password.
   - Enter your personal or business information.
   - Add a valid payment method.
     - **Tip**: Use a virtual credit card (e.g., via services like [Privacy](https://privacy.com)) to set a spending limit and enhance security.
4. Verify your identity via SMS or a phone call.
5. Select the **Basic Support Plan** (free).
6. Complete the signup process and log in to the AWS Management Console.

---

## **2. Get AWS Access Key and Secret Access Key**

1. Log in to the [AWS Management Console](https://aws.amazon.com/console/).
2. Navigate to **IAM** (Identity and Access Management):
   - In the search bar, type "IAM" and click on the IAM service.
3. Create a new user:
   - Go to **Users** > **Add Users**.
   - Enter a username (e.g., `terraform-user`).
   - Select **Access key - Programmatic access**.
4. Assign permissions:
   - Attach the **AdministratorAccess** policy.
5. Download the credentials:
   - Save the **Access Key ID** and **Secret Access Key** securely.
   - You will use these credentials when configuring the AWS CLI.

---

## **3. Configure Billing Alarms**

1. Go to the [AWS Billing Dashboard](https://console.aws.amazon.com/billing/home).
2. Set up a billing alarm:
   - Navigate to **Budgets** > **Create Budget**.
   - Choose **Cost Budget**.
3. Set your budget threshold:
   - Enter the monthly cost limit (e.g., $10 for free-tier usage).
4. Configure notifications:
   - Add your email address to receive notifications.
5. Save the budget and confirm the alarm setup.

---

## **4. Configure AWS CLI**

1. Install the AWS CLI:
   - Follow the [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
2. Run the following command to configure the AWS CLI:
   ```bash
   aws configure
   ```
3. Provide your Access Key ID, Secret Access Key, and default region (e.g., us-east-1).

## **5. Manage Private Keys for EC2**

1. Generate a private key locally:
   ```bash
   ssh-keygen -t rsa -b 2048 -f ~/.ssh/aws-key.pem
   chmod 600 ~/.ssh/aws-key.pem
   ```
2. Import the public key into AWS:
   - Log in to the AWS Management Console.
   - Navigate to EC2 > Key Pairs > Create Key Pair > Import Key Pair.
   - Upload the public key from:
      ```bash 
      cat ~/.ssh/aws-key.pem.pub
      ```
3. Assign the key pair to your EC2 instance during its creation.

## **6. Verify Setup** 
```bash 
aws sts get-caller-identity
ssh -i ~/.ssh/aws-key.pem ec2-user@<EC2_INSTANCE_PUBLIC_IP>
```

## **7. Next Steps**
After setting up AWS Cloud, you are ready to provision infrastructure using Terraform and manage deployments with Ansible. Refer to the project documentation for detailed steps.
   