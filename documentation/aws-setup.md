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
   