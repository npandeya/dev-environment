import boto3

# Initialize the S3 client
s3_client = boto3.client('s3')

# Configuration
bucket_name = 'devsecops-demo-bucket-sdk'
file_to_upload = 'demo.txt'

# Step 1: Create the S3 bucket
print("Creating S3 bucket...")
current_region = boto3.session.Session().region_name

if current_region == 'us-east-1':
    s3_client.create_bucket(Bucket=bucket_name)
else:
    s3_client.create_bucket(
        Bucket=bucket_name,
        CreateBucketConfiguration={'LocationConstraint': current_region}
    )
print(f"Bucket '{bucket_name}' created successfully in region '{current_region}'.")

# Step 2: Upload a file to the bucket
print("Creating and uploading file...")
with open(file_to_upload, 'w') as f:
    f.write("DevSecOps is awesome!")

s3_client.upload_file(file_to_upload, bucket_name, file_to_upload)
print(f"File '{file_to_upload}' uploaded successfully.")

# Print bucket and file details
print(f"Bucket Name: {bucket_name}")
print(f"Uploaded File URL: https://{bucket_name}.s3.{current_region}.amazonaws.com/{file_to_upload}")
