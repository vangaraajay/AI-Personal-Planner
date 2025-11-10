#!/bin/bash
set -e

echo "🚀 Starting AI Personal Planner deployment..."

# --- CONFIG ---
PY_VERSION="3.11"              # Match your Lambda runtime (e.g. python3.11)
LAMBDA_DIR="lambda"
TERRAFORM_DIR="terraform"
ZIP_PATH="${TERRAFORM_DIR}/lambda.zip"
REQUIREMENTS_FILE="${LAMBDA_DIR}/requirements.txt"
REGION="us-east-1"             # <-- change if your AWS region differs

# --- STEP 1: Clean old build ---
echo "🧹 Cleaning previous builds..."
rm -f ${ZIP_PATH}

# --- STEP 2: Build Lambda dependencies in Amazon Linux (Docker) ---
echo "📦 Building Lambda deployment package in Amazon Linux..."
docker run --rm \
  -v "$(pwd)":/app \
  -w /app/${LAMBDA_DIR} \
  amazonlinux:2 \
  /bin/bash -c "
    yum install -y python3 python3-pip zip > /dev/null &&
    pip3 install --upgrade pip &&
    pip3 install -r ${REQUIREMENTS_FILE} -t . &&
    zip -r9 /app/${ZIP_PATH} . -x '*.pyc' '__pycache__/*'
  "

echo "✅ Lambda deployment package created at ${ZIP_PATH}"

# --- STEP 3: Deploy Terraform infrastructure ---
echo "🏗️ Deploying infrastructure with Terraform..."
cd ${TERRAFORM_DIR}
terraform init -input=false
terraform plan -input=false
terraform apply -auto-approve

# --- STEP 4: Get outputs and update .env file ---
echo "⚙️ Updating environment variables..."
API_URL=$(terraform output -raw api_gateway_url)
API_KEY=$(terraform output -raw api_key)
FRONTEND_URL=$(terraform output -raw frontend_url)
S3_BUCKET=$(terraform output -raw s3_bucket_name)
cd ../client

cat > .env << EOF
VITE_API_URL=${API_URL}
VITE_API_KEY=${API_KEY}
EOF

# --- STEP 5: Build and upload frontend ---
echo "🌐 Building and uploading frontend..."
npm install
npm run build
aws s3 sync dist/ s3://${S3_BUCKET}/ --delete --region ${REGION}

cd ..

# --- STEP 6: Done! ---
echo "✅ Deployment complete!"
echo ""
echo "🌍 Your app is available at: ${FRONTEND_URL}"
echo "🔑 API URL: ${API_URL}"
echo ""
echo "⚠️ Note: CloudFront may take 5–15 minutes to fully propagate."
