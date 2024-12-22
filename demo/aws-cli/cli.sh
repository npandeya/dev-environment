aws s3api create-bucket --bucket devsecops-demo-bucket --region us-east-1
echo "DevSecOps is awesome" > demo.txt
aws s3 cp demo.txt s3://devsecops-demo-bucket/
aws s3 rm s3://devsecops-demo-bucket --recursive
aws sts get-caller-identity
aws iam list-roles
aws iam list-attached-user-policies --user-name $(aws iam get-user --query 'User.UserName' --output text)
