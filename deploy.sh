#!/bin/bash

set -e

echo "🚀 Starting AI Personal Planner deployment..."

# Step 1: Create Lambda deployment package
echo "📦 Creating Lambda deployment package..."
cd lambda
pip3 install -r requirements.txt -t .
zip -r ../terraform/lambda.zip . -x "*.pyc" "__pycache__/*"
cd ..

# Step 2: Deploy Terraform infrastructure
echo "🏗️ Deploying infrastructure with Terraform..."
cd terraform
terraform init
terraform plan
terraform apply -auto-approve

# Step 3: Get outputs and update .env file
echo "⚙️ Updating environment variables..."
API_URL=$(terraform output -raw api_gateway_url)
API_KEY=$(terraform output -raw api_key)
FRONTEND_URL=$(terraform output -raw frontend_url)

cd ../client
cat > .env << EOF
REACT_APP_API_URL=${API_URL}
REACT_APP_API_KEY=${API_KEY}
EOF

# Step 4: Build and upload frontend
echo "🌐 Building and uploading frontend..."
npm install
npm run build
S3_BUCKET=$(cd ../terraform && terraform output -raw s3_bucket_name)
aws s3 sync dist/ s3://${S3_BUCKET}/ --delete

cd ..

echo "✅ Deployment complete!"
echo ""
echo "🌍 Your app is available at: ${FRONTEND_URL}"
echo "🔑 API URL: ${API_URL}"
echo ""
echo "Note: CloudFront may take 5-15 minutes to fully propagate."