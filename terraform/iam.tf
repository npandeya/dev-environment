# IAM Role for EC2 instances
resource "aws_iam_role" "ec2_instance_role" {
  name = "ec2-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Attach managed policy to the IAM Role - EBS CSI Driver
resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

# Custom policy for KMS
resource "aws_iam_policy" "kms_policy" {
  name        = "ec2-kms-policy"
  description = "Custom policy to allow KMS actions"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach custom policy to the IAM Role
resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}

# Create IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}
