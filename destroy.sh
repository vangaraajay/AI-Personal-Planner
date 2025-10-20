#!/bin/bash

set -e

echo "🗑️ Starting AI Personal Planner destruction..."

# Step 1: Empty S3 bucket before destruction
echo "🧹 Emptying S3 bucket..."
cd terraform
if terraform state list | grep -q "aws_s3_bucket.frontend"; then
    S3_BUCKET=$(terraform output -raw s3_bucket_name)
    aws s3 rm s3://${S3_BUCKET}/ --recursive
    echo "S3 bucket emptied"
fi

# Step 2: Destroy Terraform infrastructure
echo "Destroying infrastructure..."
terraform destroy -auto-approve

# Step 3: Clean up local files
echo "Cleaning up local files..."
rm -f lambda.zip
cd ../lambda
rm -rf __pycache__/
find . -name "*.pyc" -delete
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# Step 4: Reset environment file
echo "Resetting environment file..."
cd ../client
cat > .env << EOF
REACT_APP_API_URL=YOUR_API_GATEWAY_URL_HERE
REACT_APP_API_KEY=YOUR_API_KEY_HERE
EOF

cd ..

echo "Destruction complete!"