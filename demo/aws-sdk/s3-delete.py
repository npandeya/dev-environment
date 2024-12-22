import boto3

# Initialize the S3 client
s3_client = boto3.client('s3')

# Configuration
bucket_name = 'devsecops-demo-bucket-sdk'
file_to_delete = 'demo.txt'

# Step 1: Delete the file from the bucket
print(f"Deleting file '{file_to_delete}' from bucket '{bucket_name}'...")
s3_client.delete_object(Bucket=bucket_name, Key=file_to_delete)
print(f"File '{file_to_delete}' deleted successfully.")

# Step 2: Delete the bucket
print(f"Deleting bucket '{bucket_name}'...")
s3_client.delete_bucket(Bucket=bucket_name)
print(f"Bucket '{bucket_name}' deleted successfully.")
